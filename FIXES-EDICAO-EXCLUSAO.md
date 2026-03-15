# Fixes de Edição e Exclusão — Plano Detalhado
**Data:** 2026-03-15
**Prioridade:** P0
**Foco:** Tornar edição e exclusão 100% confiáveis + botão de excluir na criação

---

## DIAGNÓSTICO: Por que edição/exclusão são lentas e quebram

### Fluxo atual de EDIÇÃO de evento:
```
1. Usuário: "renomeia consulta para dermatologista"
2. AI Agent identifica intenção → chama tool editar_eventos
3. Tool faz HTTP POST → webhook /editar-eventos (OUTRO workflow)
4. Webhook recebe → Edit Fields3 → monta critérios de busca
5. Code node → monta query Supabase
6. Get many rows → busca eventos que batem
7. Information Extractor (LLM!) → IA decide qual evento editar  ← GARGALO #1
8. Edit Fields5 → monta campos para UPDATE
9. Get a row1 → busca detalhes completos
10. antiduplicados2 → remove duplicatas
11. Code2 → prepara UPDATE
12. Update a row1 → UPDATE no Supabase
13. Se Google conectado:
    - descriptografar token → refresh token → PATCH Google Calendar
14. Resposta volta pro AI Agent
```

**São 14+ passos, 2 chamadas de IA (AI Agent + Information Extractor), e 1 sub-webhook HTTP.**

### Fluxo atual de EXCLUSÃO de evento:
```
1. AI Agent → tool excluir_evento → HTTP POST /excluir-evento-total
2. Webhook → Get a row (buscar evento por ID)
3. buscar_conexao_user2 → checar se tem Google
4. Se Google: descriptografar → refresh → DELETE Google Calendar
5. delete_supabase → DELETE do Supabase
6. Resposta volta
```

**Exclusão é mais simples, mas depende da IA ter achado o ID certo.**

### Por que RENAME quebra:
No node `Edit Fields5`:
```javascript
novo_nome = $('Editar eventos - webhook').item.json?.body?.novo_nome_evento
            || $json?.data?.[0]?.output?.[0]?.nome
```
Se `novo_nome_evento` vier vazio ou se o Information Extractor não retornar o evento correto, o UPDATE sobrescreve com dados errados. E o `Update a row1` atualiza **TODOS os 4 campos de uma vez** (nome, descrição, início, fim) — se algum vier vazio/null, sobrescreve com vazio.

### Problemas confirmados:
1. **Update a row1** atualiza 4 campos simultaneamente — campos não alterados podem ser sobrescritos com vazio
2. **Information Extractor** adiciona ~5-10s de latência (é outra chamada de IA)
3. **Sub-webhook HTTP** adiciona latência de rede
4. **Redis down** impede o AI Agent de ter contexto para identificar o evento

---

## FIX #1: BOTÃO DE EXCLUIR NA CRIAÇÃO DO EVENTO

### A ideia:
Ao criar um evento, ao invés de mandar só texto, mandar uma **mensagem interativa do WhatsApp** com botão "Excluir". Se o user clica, exclui direto pelo ID — sem busca, sem IA, sem ambiguidade.

### É possível?
**SIM.** A API do WhatsApp Business suporta mensagens interativas com botões de resposta rápida. Funciona assim:

1. O n8n envia mensagem tipo `interactive` ao invés de `text`
2. O WhatsApp renderiza botões clicáveis
3. Quando o user clica, o WhatsApp envia uma mensagem de volta com o `button_reply.id`
4. O webhook do n8n recebe e processa

### Limitações do WhatsApp:
- Máximo **3 botões** por mensagem
- Título do botão: máximo **20 caracteres**
- O `id` do botão pode ter até 256 caracteres (suficiente para o event ID)
- Botões são tipo `reply` (não URL) — perfeito para ações internas

### Como implementar:

#### Passo 1 — Trocar o template de evento por mensagem interativa

**ONDE:** Workflow `Calendar WebHooks` → após criar o evento no Supabase, antes de enviar a confirmação.

**HOJE** (node `HTTP Request` que envia template `novo_evento_do_usuario`):
```json
{
  "messaging_product": "whatsapp",
  "to": "USER_PHONE",
  "type": "template",
  "template": {
    "name": "novo_evento_do_usuario",
    "language": { "code": "pt_BR" },
    "components": [{
      "type": "body",
      "parameters": [
        { "type": "text", "text": "NOME_EVENTO" },
        { "type": "text", "text": "DATA_FORMATADA" }
      ]
    }]
  }
}
```

**NOVO** (substituir por mensagem interativa):
```json
{
  "messaging_product": "whatsapp",
  "to": "USER_PHONE",
  "type": "interactive",
  "interactive": {
    "type": "button",
    "body": {
      "text": "✅ Evento agendado!\n📅 NOME_EVENTO\n⏰ DATA_FORMATADA"
    },
    "action": {
      "buttons": [
        {
          "type": "reply",
          "reply": {
            "id": "evt_del_EVENT_UUID",
            "title": "🗑️ Excluir"
          }
        }
      ]
    }
  }
}
```

**No n8n, o body JSON ficaria:**
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: '✅ Evento agendado!\n📅 '
        + String($json.event_name || '')
        + '\n⏰ '
        + String($json.data_formatada || '')
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: {
            id: 'evt_del_' + String($json.uuid || $json.id || ''),
            title: '🗑️ Excluir'
          }
        }
      ]
    }
  }
}
}}
```

#### Passo 2 — Handler de botão no webhook principal

**ONDE:** Workflow `Fix Conflito v2` → node `premium` (webhook) ou logo após `Evolution API- Take all`

Quando o user clica no botão, o WhatsApp envia um payload diferente:
```json
{
  "messages": [{
    "type": "interactive",
    "interactive": {
      "type": "button_reply",
      "button_reply": {
        "id": "evt_del_UUID_DO_EVENTO",
        "title": "🗑️ Excluir"
      }
    }
  }]
}
```

**Implementação no n8n:**

1. Após `Evolution API- Take all`, adicionar um **IF node**:
   - Condição: `{{ $json.messageType }}` é `interactiveMessage` ou `buttonResponseMessage`
   - OU: `{{ $json.conversation }}` começa com `evt_del_` ou `evt_edit_`

2. Se TRUE → branch de ação rápida:
   ```
   IF (começa com "evt_del_") →
     Extrair UUID: {{ $json.conversation.replace('evt_del_', '') }}
     → Supabase: DELETE FROM calendar WHERE uuid = UUID AND user_id = USER_ID
     → Se Google conectado: DELETE evento do Google Calendar
     → Responder: "🗑️ Evento excluído!"
   ```

3. Se FALSE → continuar fluxo normal (AI Agent)

**Vantagens:**
- Exclusão em **1 clique** — sem digitar, sem ambiguidade
- Latência: ~2s (direto no Supabase, sem IA)
- Zero chance de excluir o evento errado
- Funciona mesmo com Redis down

#### Passo 3 — Opcional: Botão de editar também

Pode adicionar até 3 botões. Sugestão:
```json
{
  "buttons": [
    {
      "type": "reply",
      "reply": { "id": "evt_del_UUID", "title": "🗑️ Excluir" }
    },
    {
      "type": "reply",
      "reply": { "id": "evt_edit_UUID", "title": "✏️ Editar" }
    }
  ]
}
```

Quando user clica "✏️ Editar":
- Responder: "O que quer mudar? (nome, data/hora, ou ambos)"
- Guardar o UUID em memória temporária (Supabase ou variável)
- Próxima mensagem do user → fazer UPDATE direto pelo UUID

---

## FIX #2: CORRIGIR UPDATE QUE SOBRESCREVE CAMPOS

### O problema:
Node `Update a row1` no workflow `Calendar WebHooks` faz UPDATE de 4 campos simultaneamente:
```
event_name  = novo_nome
desc_event  = nova_desc
start_event = novo_comeco
end_event   = novo_fim
```

Se o user só pediu para mudar o nome, os campos `novo_comeco` e `novo_fim` vêm vazios → sobrescreve com vazio → evento perde data/hora.

### Correção:

**Opção A — Condicional no n8n (recomendada):**

Substituir o node `Update a row1` por um **Code node** que monta o UPDATE dinamicamente:

```javascript
// Code node: Montar UPDATE só com campos alterados
const uuid = $json.sessao;
const updates = {};

const novoNome = $json.novo_nome;
const novaDesc = $json.nova_desc;
const novoComeco = $json.novo_comeco;
const novoFim = $json.novo_fim;

// Só incluir campo se veio preenchido
if (novoNome && novoNome.trim() !== '') {
  updates.event_name = novoNome;
}
if (novaDesc && novaDesc.trim() !== '') {
  updates.desc_event = novaDesc;
}
if (novoComeco && novoComeco.trim() !== '') {
  updates.start_event = novoComeco;
}
if (novoFim && novoFim.trim() !== '') {
  updates.end_event = novoFim;
}

// Se nenhum campo para atualizar, retornar erro
if (Object.keys(updates).length === 0) {
  return [{ json: { error: true, message: 'Nenhum campo para atualizar' } }];
}

return [{ json: { uuid, updates, fieldsToUpdate: Object.keys(updates) } }];
```

Depois, usar um **Supabase node** com HTTP Request ao invés do node nativo, fazendo PATCH:
```
PATCH https://ldbdtakddxznfridsarn.supabase.co/rest/v1/calendar?uuid=eq.UUID
Body: { campos que vieram preenchidos }
```

**Opção B — Manter o node Supabase mas com valores fallback:**

No node `Edit Fields5`, alterar cada campo para manter o valor original se não houver novo:
```
novo_nome  = body.novo_nome_evento || output.nome_original
nova_desc  = body.novo_desc_evento || output.desc_original
novo_comeco = body.novo_inicio_evento || output.start_original
novo_fim   = body.novo_fim_evento || output.end_original
```

---

## FIX #3: ELIMINAR O INFORMATION EXTRACTOR (GARGALO DE LATÊNCIA)

### O problema:
O fluxo de edição usa um `Information Extractor` (LLM) para decidir qual evento editar quando a busca retorna múltiplos resultados. Isso adiciona 5-10s de latência.

### Correção:

**Se veio do botão (Fix #1):** não precisa de busca nem de IA — já tem o UUID.

**Se veio por texto:** simplificar a lógica:
1. Buscar por nome (ILIKE) + user_id
2. Se achou 1 → editar direto
3. Se achou N → listar para o user escolher (sem usar IA para decidir)
4. Se achou 0 → "Não encontrei"

Substituir o `Information Extractor` por um **Code node** simples:
```javascript
const results = $('Get many rows').item.json;
const searchName = $('Editar eventos - webhook').item.json.body.nome_evento;

if (!results || results.length === 0) {
  return [{ json: { action: 'not_found' } }];
}

if (results.length === 1) {
  return [{ json: { action: 'edit', event: results[0] } }];
}

// Múltiplos resultados — tentar match exato
const exact = results.find(r =>
  r.event_name.toLowerCase() === searchName.toLowerCase()
);
if (exact) {
  return [{ json: { action: 'edit', event: exact } }];
}

// Ainda ambíguo — listar para o user
return [{ json: { action: 'ask_user', events: results } }];
```

**Ganho esperado:** -5 a -10s na edição de eventos.

---

## FIX #4: REDIS — RESTAURAR OU SUBSTITUIR

### Status atual:
- Host: `redis-13781.crce181.sa-east-1-2.ec2.redns.redis-cloud.com`
- Erro: `ENOTFOUND` (DNS não resolve)
- **17 nodes Redis** no workflow principal
- Impacto: debounce morto, memória de conversa morta, latência em tudo

### Opção A — Restaurar Redis Cloud:
1. Acesse https://app.redis.io
2. Verifique subscription → provavelmente expirou ou foi deletada
3. Crie nova instância free tier (30MB, suficiente)
4. Atualize credencial no n8n: Settings → Credentials → Redis

### Opção B — Redis local (recomendada para dev):
```bash
# No server 76.13.172.17:
sudo apt update && sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
redis-cli ping  # deve responder PONG
```
Depois: credencial Redis no n8n → host: `localhost`, port: `6379`, sem senha.

### Opção C — Upstash (serverless, free tier generoso):
1. Crie conta em https://upstash.com
2. Crie Redis database (região São Paulo)
3. Copie URL e token
4. Atualize credencial no n8n

**Impacto esperado:** Todas as operações de edição/exclusão ficam 5-15s mais rápidas.

---

## FIX #5: LEMBRETE RECORRENTE — gte/lte INVERTIDO

### O que está errado:
No workflow `Lembretes Total Assistente`, node `Get Recurring Reminders`:
```
next_fire_at >= NOW() + 30min   ← impossível junto com ↓
next_fire_at <= NOW() - 30min   ← nada é >= futuro E <= passado
```

### Correção (1 minuto):
1. Abrir workflow Lembretes
2. Abrir node `Get Recurring Reminders`
3. Trocar:
   - `gte {{ $now.plus({ minutes: 30 }) }}` → `lte {{ $now.plus({ minutes: 30 }) }}`
   - `lte {{ $now.minus({ minutes: 30 }) }}` → `gte {{ $now.minus({ minutes: 30 }) }}`
4. Salvar

### Referência: O node `Get Reminders (due now)1` está CORRETO:
```
next_fire_at lte NOW() + 30min ✅
next_fire_at gte NOW() - 30min ✅
```

---

## FIX #6: JANELA DE LEMBRETE 2min → 5min

### O que está errado:
Node `Get Events (in 30 min)` (para tipo "lembrete"):
```
start_event < NOW() + 2 minutos  ← janela muito estreita
```
Se o schedule falha 2x seguidas, o lembrete é perdido.

### Correção:
Mudar `{{ $now.plus({ minutes: 2 }) }}` para `{{ $now.plus({ minutes: 5 }) }}`.

---

## FIX #7: PROMPT DA IA — REMOVER LIMITES E ADICIONAR CONTEXTO

### Adicionar ao system prompt (seção "O QUE VOCÊ NÃO FAZ"):
```
• NÃO define limites de gasto por categoria (funcionalidade não disponível)
• NÃO cria planos de investimento, metas financeiras ou simulações
```

### Adicionar às regras técnicas:
```
• Ao registrar ENTRADA/RECEITA, diga "✅ Entrada registrada!" (nunca "Registro registrado")
• Categorize salários/freelance como "Renda", não "Outros"
```

---

## FIX #8: UX GOOGLE CALENDAR DESCONECTADO

### Quando detectar que Google não está conectado, enviar botão CTA:

```javascript
={{
{
  messaging_product: 'whatsapp',
  to: USER_PHONE,
  type: 'interactive',
  interactive: {
    type: 'cta_url',
    body: {
      text: '📅 Seu Google Calendar não está conectado.\nConecte para sincronizar seus eventos automaticamente!'
    },
    action: {
      name: 'cta_url',
      parameters: {
        display_text: '🔗 Conectar Google Calendar',
        url: 'https://totalassistente.com.br/agenda'
      }
    }
  }
}
}}
```

**ONDE:** No workflow `Fix Conflito v2`, quando o `If Conectado ao Google?` retorna FALSE.

---

## CHECKLIST FINAL DE IMPLEMENTAÇÃO

### Já corrigidos: ✅
- [x] Tabela `log_total` criada
- [x] "Entrada registrada" no prompt

### Quick fixes (< 5 min cada):
- [ ] Fix #5: Inverter gte/lte no Get Recurring Reminders
- [ ] Fix #6: Janela 2min → 5min
- [ ] Fix #7: Atualizar prompt (limites + categorias)

### Fixes médios (15-30 min cada):
- [ ] Fix #4: Restaurar Redis (local ou cloud)
- [ ] Fix #2: UPDATE condicional (só campos alterados)
- [ ] Fix #3: Trocar Information Extractor por Code node
- [ ] Fix #8: Botão CTA Google Calendar

### Fix principal (30-60 min):
- [ ] Fix #1: Botão de excluir na criação + handler no webhook

### Ordem recomendada:
```
1. Fix #5 + #6 (2 min total) — lembretes voltam a funcionar
2. Fix #4 (10 min) — Redis restaura debounce e memória
3. Fix #2 (15 min) — edição para de sobrescrever campos
4. Fix #3 (15 min) — remove gargalo do Information Extractor
5. Fix #1 (30-60 min) — botão de excluir na criação
6. Fix #7 + #8 (10 min) — prompt e UX Google
```

**Tempo total estimado: ~1h30**
**Impacto: edição/exclusão passam de 14-56s para ~2-5s (via botão)**
