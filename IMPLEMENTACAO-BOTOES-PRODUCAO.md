# Implementação de Botões — Baseado no Workflow de Produção
**Data:** 2026-03-16
**Workflow analisado:** Fix Conflito v2 (produção)
**Objetivo:** Adicionar botões de Excluir e Editar em eventos E financeiro

---

## PROBLEMA ATUAL

Os templates `novo_evento_do_usuario` e `nova_transacao_do_usuario` estão dando erro `(#131009) Parameter value is not valid` quando copiados. A mensagem interativa resolve isso porque **não usa templates** — é uma mensagem livre gerada na hora.

---

## MAPA DO WORKFLOW DE PRODUÇÃO (nodes relevantes)

### Fluxo de EVENTO ÚNICO (criar):
```
AI Agent → Code in JavaScript → Switch2 (branch 2: criar_evento)
  → Code in JavaScript1 (formata data)
  → If7 (1 evento?)
    SIM → lastGet3 → If2 → Redis2
      → HTTP - Create Calendar Tool2 (cria no Supabase)
      → Buscar Conflitos (Unico)
      → Tem Conflito?
        SIM → Aggregate6 → Aviso Conflito (Unico) → HTTP Request ← ESTE NODE
        NÃO → Aggregate8 → HTTP Request ← ESTE NODE
      → Get a row → Create a row1 (log)
```

**Node a alterar: `HTTP Request`** (envia template `novo_evento_do_usuario`)

### Fluxo de GASTO/ENTRADA ÚNICO (criar):
```
Switch2 (branch 1: registrar_gasto)
  → If4 (1 item?)
    SIM → lastGet2 → If → Redis
      → HTTP Request — Basic Create Template ← ESTE NODE
      → HTTP - Create Tool1 (registra no Supabase)
      → Get a row → Create a row1 (log)
```

**Node a alterar: `HTTP Request — Basic Create Template`** (envia template `nova_transacao_do_usuario`)

### Fluxo PADRÃO (respostas do AI Agent — editar, excluir, buscar):
```
Switch2 (branch 0: padrao)
  → lastGet1 → If18 → Redis3
    → Send message ← envia texto puro
    → Get a row → Create a row1 (log)
```

### Fluxo de EVENTO BATCH (múltiplos):
```
If7 (múltiplos)
  → HTTP - Create Calendar Tool6 (cria todos)
  → Aggregate5 → lastGet7 → If9 → Redis8
  → Set Range (Batch) → Buscar Conflitos (Batch) → ...
  → Aggregate10 → Send message6 ← envia texto puro
```

### Fluxo de GASTO BATCH (múltiplos):
```
If4 (múltiplos)
  → HTTP - Create Tool2 (registra todos)
  → Aggregate2 → lastGet5 → If5 → Redis6
  → Send message1 ← envia texto puro (sem template)
```

### Fluxo de LEMBRETE RECORRENTE:
```
Switch2 (branch 3: evento_recorrente)
  → lastGet10 → If22 → Redis10
  → HTTP - Create Calendar Tool3 (cria no Supabase)
  → Send message5 ← envia texto puro
```

---

## ALTERAÇÃO 1: Botão de excluir em EVENTO (único)

### Node: `HTTP Request`
**Posição no workflow:** (6016, 1712)
**Connections FROM:** `Aviso Conflito (Unico)` e `Aggregate8`
**Connections TO:** `Get a row`

### Código ATUAL:
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'template',
  template: {
    name: 'novo_evento_do_usuario',
    language: { code: 'pt_BR' },
    components: [
      {
        type: 'body',
        parameters: [
          { type: 'text', text: String($('Switch2').item.json.parsed_output.tool[0].nome_evento || '') },
          { type: 'text', text: String($('Code in JavaScript1').item.json.data_inicio_evento_formatado || '') }
        ]
      }
    ]
  }
}
}}
```

### Código NOVO (com botões):
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: '✅ Evento agendado!\n\n📅 '
        + String($('Switch2').item.json.parsed_output.tool[0].nome_evento || 'Sem título')
        + '\n⏰ '
        + String($('Code in JavaScript1').item.json.data_inicio_evento_formatado || '')
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: {
            id: 'evt_del_' + String($('HTTP - Create Calendar Tool2').item.json.uuid || $('HTTP - Create Calendar Tool2').item.json.id || ''),
            title: '🗑️ Excluir'
          }
        },
        {
          type: 'reply',
          reply: {
            id: 'evt_edit_' + String($('HTTP - Create Calendar Tool2').item.json.uuid || $('HTTP - Create Calendar Tool2').item.json.id || ''),
            title: '✏️ Editar'
          }
        }
      ]
    }
  }
}
}}
```

> **NOTA:** O `$('HTTP - Create Calendar Tool2').item.json.uuid` precisa trazer o UUID do evento criado. Se o webhook de criação não retorna o UUID, você precisa ajustar o webhook `5e0f5e77-aea5-4784-8a85-58e8eaf49c30` (Calendar WebHooks) para retornar o UUID na resposta.

### Se o UUID não estiver disponível nesse ponto:

Alternativa: usar o nome + data como identificador no botão:
```javascript
id: 'evt_del_' + encodeURIComponent(
  String($('Switch2').item.json.parsed_output.tool[0].nome_evento || '')
  + '|'
  + String($('Switch2').item.json.parsed_output.tool[0].data_inicio_evento || '')
)
```

Aí no handler, você busca por nome + data ao invés de UUID direto.

---

## ALTERAÇÃO 2: Botão de excluir em FINANCEIRO (único)

### Node: `HTTP Request — Basic Create Template`
**Posição no workflow:** (4096, 368)
**Connections FROM:** `Redis`
**Connections TO:** `HTTP - Create Tool1`

### Código ATUAL:
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'template',
  template: {
    name: 'nova_transacao_do_usuario',
    language: { code: 'pt_BR' },
    components: [
      {
        type: 'body',
        parameters: [
          { type: 'text', text: String($('Switch2').item.json.parsed_output.tool[0].nome_gasto || '') },
          { type: 'text', text: String($('Switch2').item.json.parsed_output.tool[0].valor_gasto || '') }
        ]
      }
    ]
  }
}
}}
```

### Código NOVO (com botão):
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: '✅ '
        + (String($('Switch2').item.json.parsed_output.tool[0].entra_sai_gasto || '') === 'entrada' ? 'Entrada' : 'Gasto')
        + ' registrado!\n\n📝 '
        + String($('Switch2').item.json.parsed_output.tool[0].nome_gasto || '')
        + '\n💰 R$'
        + String($('Switch2').item.json.parsed_output.tool[0].valor_gasto || '')
        + '\n📂 '
        + String($('Switch2').item.json.parsed_output.tool[0].categoria_gasto || '')
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: {
            id: 'fin_del_' + String($('Switch2').item.json.parsed_output.tool[0].nome_gasto || '') + '|' + String($('Switch2').item.json.parsed_output.tool[0].valor_gasto || ''),
            title: '🗑️ Desfazer'
          }
        }
      ]
    }
  }
}
}}
```

> **NOTA:** Aqui o template roda ANTES do `HTTP - Create Tool1` (que registra no Supabase). Isso significa que no momento do envio, o registro ainda não foi criado — não temos o ID. Por isso uso nome+valor como identificador. Uma alternativa melhor seria **inverter a ordem**: primeiro `HTTP - Create Tool1`, depois enviar a mensagem com o ID retornado.

### Inverter a ordem (recomendado):

**Hoje:**
```
Redis → HTTP Request — Basic Create Template → HTTP - Create Tool1 → Get a row
```

**Melhor:**
```
Redis → HTTP - Create Tool1 → HTTP Request — Basic Create Template (com botão) → Get a row
```

Basta trocar as connections no n8n:
1. Desconectar `Redis` → `HTTP Request — Basic Create Template`
2. Conectar `Redis` → `HTTP - Create Tool1`
3. Conectar `HTTP - Create Tool1` → `HTTP Request — Basic Create Template`
4. Manter `HTTP Request — Basic Create Template` → `Get a row`

Aí o botão pode usar o ID real retornado pelo Supabase:
```javascript
id: 'fin_del_' + String($('HTTP - Create Tool1').item.json.id || $('HTTP - Create Tool1').item.json.uuid || '')
```

---

## ALTERAÇÃO 3: Handler de botões no início do workflow

### Onde adicionar:

Logo após o `Switch` que verifica o tipo de mensagem (antes do fluxo normal), adicionar detecção de clique de botão.

### Como o WhatsApp envia cliques de botão:

Quando o user clica num botão, o webhook recebe um payload onde:
- `messageType` = `interactiveMessage` ou `buttonResponseMessage`
- O `conversation` ou `body` contém o `id` do botão clicado

### Implementação — Adicionar IF node:

**Nome:** `É Clique de Botão?`
**Posição:** Logo após `Evolution API- Take all`, antes do fluxo de classificação

**Condição:**
```
{{ $json.conversation }}.startsWith('evt_del_')
OR {{ $json.conversation }}.startsWith('evt_edit_')
OR {{ $json.conversation }}.startsWith('fin_del_')
```

**Se TRUE (é botão) → 3 branches:**

#### Branch A: `evt_del_` (excluir evento)
```
1. Code node: extrair UUID
   const btnId = $json.conversation;
   const uuid = btnId.replace('evt_del_', '');
   return [{ json: { uuid, user_id: $('setar_user').item.json.id_user } }];

2. Supabase node: DELETE
   DELETE FROM calendar WHERE uuid = uuid AND user_id = user_id

3. Se Google conectado: DELETE do Google Calendar (mesmo fluxo do excluir-evento-total)

4. Send message: "🗑️ Evento excluído!"
```

#### Branch B: `evt_edit_` (editar evento)
```
1. Code node: extrair UUID
   const uuid = $json.conversation.replace('evt_edit_', '');

2. Send message: "✏️ O que quer mudar?\n\n1️⃣ Nome\n2️⃣ Data/horário\n3️⃣ Ambos"

3. Guardar o UUID no Redis:
   SET {{ phone }}_editing = uuid (TTL 120s)

4. Na próxima mensagem do user, checar se existe _editing no Redis
   Se sim → fazer UPDATE direto pelo UUID com o que o user pediu
```

#### Branch C: `fin_del_` (desfazer gasto)
```
1. Code node: extrair ID
   const btnId = $json.conversation;
   const id = btnId.replace('fin_del_', '');

2. Supabase node: DELETE
   DELETE FROM spent WHERE id = id AND user_id = user_id

3. Send message: "🗑️ Registro desfeito!"
```

**Se FALSE → continuar fluxo normal (classificação, AI Agent, etc)**

---

## ALTERAÇÃO 4: Prompt do AI Agent — Contexto dos botões

### Adicionar ao system prompt (seção REGRAS TÉCNICAS):

```
• Quando o usuário enviar algo como "evt_del_..." ou "fin_del_..." ou "evt_edit_...",
  ignore — isso é tratado automaticamente pelo sistema antes de chegar até você.
```

### Adicionar ao system prompt (seção O QUE VOCÊ NÃO FAZ):

```
• NÃO define limites de gasto por categoria (funcionalidade não disponível)
• NÃO cria planos de investimento, metas financeiras ou simulações
```

### Alterar no system prompt (regra de receitas):

```
• Ao registrar ENTRADA/RECEITA, diga "✅ Entrada registrada!" (nunca "Registro registrado")
• Categorize salários/freelance como "Renda", não "Outros"
```

---

## ALTERAÇÃO 5: Botões nos fluxos BATCH (múltiplos itens)

### Eventos batch (node `Send message6`):
Para múltiplos eventos, não dá pra ter 1 botão por evento (limite de 3 botões). Solução:

**Trocar `Send message6` por HTTP Request com lista e botão "Desfazer tudo":**
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').first().json.body.user_phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: String($('Code in JavaScript').first().json.parsed_output.mensagem || '')
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: {
            id: 'batch_del_eventos',
            title: '🗑️ Desfazer tudo'
          }
        }
      ]
    }
  }
}
}}
```

### Gastos batch (node `Send message1`):
Mesma lógica — botão "Desfazer tudo" que remove os últimos N registros.

---

## ALTERAÇÃO 6: Lembretes recorrentes (node `Send message5`)

**Trocar `Send message5` por HTTP Request com botão de exclusão:**
```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('premium').item.json.body.user_phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: String($('Code in JavaScript').item.json.parsed_output.mensagem || '')
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: {
            id: 'rec_del_' + String($('HTTP - Create Calendar Tool3').item.json.uuid || $('HTTP - Create Calendar Tool3').item.json.id || ''),
            title: '🗑️ Excluir'
          }
        }
      ]
    }
  }
}
}}
```

---

## RESUMO DAS ALTERAÇÕES

| # | Node atual | Alteração | Tipo |
|---|-----------|-----------|------|
| 1 | `HTTP Request` (evento único) | Template → Interactive com botões Excluir/Editar | JSON body |
| 2 | `HTTP Request — Basic Create Template` (gasto único) | Template → Interactive com botão Desfazer | JSON body |
| 3 | Novo: `É Clique de Botão?` | IF node após Evolution API | Novo node |
| 4 | Novo: handler `evt_del_` | Code + Supabase DELETE + Send | 3 novos nodes |
| 5 | Novo: handler `evt_edit_` | Code + Send + Redis SET | 3 novos nodes |
| 6 | Novo: handler `fin_del_` | Code + Supabase DELETE + Send | 3 novos nodes |
| 7 | `Send message6` (eventos batch) | Text → Interactive com "Desfazer tudo" | JSON body |
| 8 | `Send message5` (lembrete recorrente) | Text → Interactive com Excluir | JSON body |
| 9 | `AI Agent` system prompt | Adicionar regras de limites, receitas, botões | Texto |

### Nodes existentes que NÃO mudam:
- `Send message` (respostas padrão do AI Agent) — mantém texto puro
- `Send message3` e `Send message4` — parecem ser fallbacks/backups
- Todo o fluxo de classificação e AI Agent
- Todos os sub-webhooks (editar-supabase, excluir-supabase, etc)

---

## ORDEM DE IMPLEMENTAÇÃO

```
1. Alterar HTTP Request (evento único) — trocar template por interactive
   → Testa: cria um evento, vê se botão aparece

2. Adicionar IF "É Clique de Botão?" + handler evt_del_
   → Testa: clica no botão, vê se exclui

3. Alterar HTTP Request — Basic Create Template (gasto único)
   → Testa: registra gasto, vê se botão aparece

4. Adicionar handler fin_del_
   → Testa: clica desfazer, vê se remove

5. Adicionar handler evt_edit_ + lógica de Redis
   → Testa: clica editar, responde, vê se edita

6. Alterar Send message5 e Send message6 (batch + recorrente)

7. Atualizar system prompt do AI Agent
```

**Cada passo pode ser testado independentemente. Se o passo 1 funcionar, já valida toda a abordagem.**

---

## POSSÍVEIS PROBLEMAS

### 1. UUID não disponível no momento do envio
Se `HTTP - Create Calendar Tool2` não retorna o UUID do evento criado, o botão não vai ter o ID correto.

**Como verificar:** Execute manualmente o webhook `5e0f5e77-aea5-4784-8a85-58e8eaf49c30` e veja o que retorna. Se não retorna UUID, adicionar `RETURNING uuid` na query de INSERT do Supabase no workflow Calendar WebHooks.

### 2. Limite de 20 caracteres no título do botão
- "🗑️ Excluir" = 11 chars ✅
- "✏️ Editar" = 10 chars ✅
- "🗑️ Desfazer" = 12 chars ✅
- "🗑️ Desfazer tudo" = 17 chars ✅

### 3. Limite de 256 caracteres no ID do botão
UUIDs têm 36 caracteres + prefixo ~8 = ~44 chars. Bem dentro do limite. ✅

### 4. Mensagem interativa só funciona na janela de 24h
No nosso caso, o user acabou de mandar mensagem → estamos dentro da janela. ✅

### 5. O `conversation` pode não trazer o button ID
Depende de como o webhook processa. Em alguns setups, o button reply vem em:
- `$json.body.interactive.button_reply.id`
- `$json.body.context.id`
- `$json.conversation`

Testar qual campo traz o ID no seu setup específico (Evolution API ou webhook direto).

---

## COMO O ID CHEGA NO BOTÃO — EXPLICAÇÃO VISUAL

### O fluxo completo, passo a passo:

```
PASSO 1: User manda "dentista amanhã às 14h"

PASSO 2: n8n cria o evento no Supabase (via webhook Calendar-Creator)
         O Supabase retorna: { id: 12345, uuid: "abc-123-def", event_name: "Dentista" }
                               ↑
                               ESTE é o ID que vai no botão

PASSO 3: O node "sucesso_google" (ou "sucesso_padrao") já pega esse ID:
         evento_id_criado = $('create_calendar_sup_google').item.json.id
                                                                    ↑
                                                          JÁ EXISTE NO WORKFLOW!

PASSO 4: Esse valor volta pro Fix Conflito v2 como resposta do
         HTTP - Create Calendar Tool2

PASSO 5: Na hora de enviar a mensagem pro WhatsApp,
         coloca esse ID dentro do botão:
         botão.id = "evt_del_12345"

PASSO 6: User vê a mensagem com o botão e clica "🗑️ Excluir"

PASSO 7: WhatsApp manda de volta pro webhook: "evt_del_12345"

PASSO 8: n8n recebe, tira o prefixo "evt_del_", fica com "12345"

PASSO 9: DELETE FROM calendar WHERE id = 12345
         → Pronto, excluído em ~2 segundos!
```

### Onde o ID já existe no workflow de produção:

O webhook `Webhook-Calendar-Creator` cria o evento e os nodes `sucesso_google` e `sucesso_padrao` já extraem o ID:

```javascript
// Node "sucesso_google" — JÁ EXISTE:
evento_id_criado = $('create_calendar_sup_google').item.json.id

// Node "sucesso_padrao" — JÁ EXISTE:
evento_id_criado = $('create_calendar_sup_google1').item.json.id
```

Esse `evento_id_criado` volta como resposta HTTP pro `HTTP - Create Calendar Tool2` no workflow principal.

### Como acessar no node do botão:

No `HTTP Request` que envia a confirmação do evento, o ID fica em:

```javascript
$('HTTP - Create Calendar Tool2').item.json.evento_id_criado
```

E no JSON do botão:

```javascript
id: 'evt_del_' + String($('HTTP - Create Calendar Tool2').item.json.evento_id_criado || '')
```

**Não precisa criar nada novo — o ID já trafega no workflow, só precisa colocar ele no JSON do botão.**

---

## PROBLEMA DESCOBERTO: O ID NÃO CHEGA NO FIX CONFLITO v2

### O que acontece:
O webhook `Calendar-Creator` tem `responseMode: lastNode`. O último node é `Create a row1` (log na tabela `log_total`), que retorna dados do LOG — não o `evento_id_criado`.

O `evento_id_criado` existe no node `sucesso_google`/`sucesso_padrao`, mas se perde porque o log roda depois.

### A correção (no workflow Calendar WebHooks):

**Adicionar 1 Set node no final de cada caminho** que retorna o ID do evento.

#### Caminho Google (após `Create a row1`):
Adicionar um **Set node** chamado `Resposta com ID`:
```
evento_id_criado = {{ $('sucesso_google').item.json.evento_id_criado }}
sucesso = true
```

#### Caminho Padrão (após `Create a row`):
Adicionar um **Set node** chamado `Resposta com ID (padrao)`:
```
evento_id_criado = {{ $('sucesso_padrao').item.json.evento_id_criado }}
sucesso = true
```

**Resultado:** O último node agora retorna `{ evento_id_criado: 12345, sucesso: true }`, que é a resposta HTTP que chega no `HTTP - Create Calendar Tool2` do Fix Conflito v2.

### Fluxo corrigido:
```
ANTES:
  sucesso_google → Create a row1 → FIM (retorna dados do log ❌)

DEPOIS:
  sucesso_google → Create a row1 → Resposta com ID → FIM (retorna ID ✅)
```

### Passo a passo no n8n:

1. Abrir workflow **Calendar WebHooks**
2. Após o node `Create a row1`, adicionar um **Set node**:
   - Nome: `Resposta com ID`
   - Campo: `evento_id_criado` = `{{ $('sucesso_google').item.json.evento_id_criado }}`
   - Campo: `sucesso` = `true`
3. Conectar `Create a row1` → `Resposta com ID`
4. Repetir para o caminho `Create a row` → `Resposta com ID (padrao)`:
   - Campo: `evento_id_criado` = `{{ $('sucesso_padrao').item.json.evento_id_criado }}`
   - Campo: `sucesso` = `true`
5. Salvar

### Depois, no Fix Conflito v2:
O botão agora funciona:
```javascript
id: 'evt_del_' + String($('HTTP - Create Calendar Tool2').item.json.evento_id_criado || '')
```

### Para financeiro — mesma lógica:

Hoje o template roda ANTES do registro no banco. Invertendo a ordem (primeiro `HTTP - Create Tool1`, depois enviar mensagem), o ID fica em:

```javascript
$('HTTP - Create Tool1').item.json.id
```

E no botão:

```javascript
id: 'fin_del_' + String($('HTTP - Create Tool1').item.json.id || '')
