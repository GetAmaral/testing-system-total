# Plano de Correção — Eventos Recorrentes, Edição/Exclusão e Lembretes
**Data:** 2026-03-15
**Prioridade:** P0 — Corrigir imediatamente
**Baseado em:** Baterias de teste 01, 02 e 03

---

## PROBLEMA 1: Edição de eventos é lenta e falha (45-68s / TIMEOUT)

### Causa provável:
O workflow de edição provavelmente faz uma busca em TODA a tabela `calendar` para encontrar o evento, sem filtro eficiente. Para recorrentes, pode estar tentando expandir todas as instâncias antes de editar.

### Plano de correção:

**Passo 1 — No workflow de edição do n8n:**
- Adicionar filtro `WHERE user_id = X AND event_name ILIKE '%nome%'` na query de busca
- Limitar busca aos próximos 30 dias ao invés de toda a tabela
- Usar índice em `event_name` + `user_id` se não existir

**Passo 2 — Para recorrentes:**
- Ao editar, perguntar: "Quer editar ESTA ocorrência ou TODAS as futuras?"
- Se "todas": atualizar o campo `rrule` diretamente, sem expandir instâncias
- Se "esta": criar uma exceção (exdate) e um evento avulso no lugar

**Passo 3 — Timeout safety:**
- Adicionar timeout de 15s no node de edição do n8n
- Se timeout: responder "Não consegui editar, tente novamente" ao invés de travar

---

## PROBLEMA 2: Exclusão de recorrentes inconsistente

### Causa provável:
- "Cancela todas as aulas de inglês" retorna "não encontrei" porque a busca pode estar filtrando por data (próximos X dias) e não encontra o evento base
- Exclusão de uma ocorrência pode estar deletando o registro inteiro ao invés de criar um `exdate`

### Plano de correção:

**Passo 1 — Botão de exclusão no momento da criação (ideia do Luiz):**

Ao criar um evento, a resposta da IA inclui um **botão interativo do WhatsApp**:

```json
{
  "type": "interactive",
  "interactive": {
    "type": "button",
    "body": {
      "text": "✅ Evento agendado!\n📅 Aula de Inglês\n🔁 Toda terça e quinta às 19h"
    },
    "action": {
      "buttons": [
        {
          "type": "reply",
          "reply": {
            "id": "delete_event_{{EVENT_ID}}",
            "title": "🗑️ Excluir"
          }
        },
        {
          "type": "reply",
          "reply": {
            "id": "edit_event_{{EVENT_ID}}",
            "title": "✏️ Editar"
          }
        }
      ]
    }
  }
}
```

**Como implementar no n8n:**
1. No node que envia a confirmação de evento criado, trocar mensagem de texto por mensagem interativa
2. Incluir o `EVENT_ID` do banco no ID do botão
3. Criar um novo branch no webhook que captura respostas de botão (`type: "interactive"`)
4. Quando o user clica "🗑️ Excluir": deletar direto pelo ID — sem busca, sem ambiguidade, sem timeout
5. Quando o user clica "✏️ Editar": perguntar o que quer mudar

**Benefícios:**
- Zero ambiguidade: o botão já tem o ID do evento
- Zero latência de busca: delete direto por ID
- UX muito melhor: 1 clique vs digitar "cancela a aula de inglês de terça"

**Passo 2 — Para exclusão via texto (fallback):**
- Buscar PRIMEIRO pelo nome exato, depois por nome parcial
- Se encontrou 1: excluir direto
- Se encontrou N: listar e pedir confirmação (como fez no teste 11.7 — bom padrão)
- Se não encontrou: buscar também em eventos inativos/passados

**Passo 3 — Exclusão de recorrentes:**
- "Cancela aula de inglês de terça": criar `exdate` para aquela data, NÃO deletar o registro
- "Cancela todas as aulas de inglês": deletar o registro base + todas as instâncias expandidas
- Sempre confirmar: "Quer excluir só esta vez ou todas as futuras?"

---

## PROBLEMA 3: Edição de gasto reverte mudanças anteriores

### Causa provável:
O workflow de edição faz UPDATE com todos os campos, sobrescrevendo valores anteriores. Se o user muda o nome, o valor volta ao original porque o workflow lê o valor original da IA ao invés do valor atual no banco.

### Plano de correção:

**No workflow de edição de gastos do n8n:**
1. Antes de fazer UPDATE, fazer SELECT do registro atual no banco
2. Só alterar os campos que o usuário pediu explicitamente
3. Manter todos os outros campos com o valor ATUAL do banco (não o original da IA)

```sql
-- ERRADO (o que provavelmente faz hoje):
UPDATE spent SET name_spent = 'Drogaria', value_spent = 150 WHERE id = X;

-- CORRETO (só atualiza o que mudou):
UPDATE spent SET name_spent = 'Drogaria' WHERE id = X;
-- value_spent mantém o valor atual (180) que foi corrigido antes
```

---

## PROBLEMA 4: Recorrência mensal TIMEOUT (68s)

### Causa provável:
Ao criar um lembrete recorrente mensal, o workflow tenta expandir todas as instâncias futuras na tabela `calendar_backup_expanded_instances`. Se expande para 12 meses ou mais, gera muitas rows e trava.

### Plano de correção:

**Passo 1 — Limitar expansão:**
- Expandir no máximo 3 meses à frente (não 12)
- Usar um cron job separado que expande o próximo mês quando necessário

**Passo 2 — Ou: não expandir mensais**
- Para recorrência mensal, armazenar só o registro base com `rrule`
- Calcular a próxima ocorrência via `next_fire_at` em tempo real
- Usar a RPC `next_occurrence` que já existe no banco

---

## PROBLEMA 5: Schedule Trigger — Risco de lembretes não dispararem

### Verificações necessárias no n8n dev:

| Item | O que verificar | Onde |
|------|----------------|------|
| 1 | Schedule trigger está **ativo**? | Workflow de lembretes → node Schedule Trigger |
| 2 | Intervalo de execução (a cada 1 min? 5 min?) | Configuração do Schedule Trigger |
| 3 | Query busca `next_fire_at <= NOW()`? | Node de query SQL/Supabase |
| 4 | Após disparar, atualiza `next_fire_at` para próxima ocorrência? | Node de update |
| 5 | Marca `remembered = true` para não repetir? | Node de update |
| 6 | Timezone configurado corretamente (America/Sao_Paulo)? | Schedule Trigger + queries |
| 7 | Tratamento de erro se WhatsApp falha ao enviar? | Error handling no workflow |

### Riscos por cenário:

```
CENÁRIO A: Schedule trigger inativo
→ IMPACTO: Nenhum lembrete dispara. Nunca.
→ VERIFICAR: Workflow de lembretes ativo no n8n dev

CENÁRIO B: next_fire_at não atualizado
→ IMPACTO: Lembrete dispara uma vez e para de funcionar
→ VERIFICAR: Se existe UPDATE de next_fire_at após disparo

CENÁRIO C: remembered não marcado
→ IMPACTO: Lembrete dispara infinitamente (a cada execução do schedule)
→ VERIFICAR: Se existe UPDATE de remembered = true

CENÁRIO D: Timezone errado
→ IMPACTO: Lembrete de 9h chega às 6h ou 12h
→ VERIFICAR: Timezone no schedule trigger e nas queries

CENÁRIO E: Erro silencioso no envio WhatsApp
→ IMPACTO: Schedule roda, lembrete "dispara" mas nunca chega
→ VERIFICAR: Error handling no node de envio
```

### Para desbloquear esta investigação:
**Preciso da API key do n8n dev** (`X-N8N-API-KEY`) para ler o workflow de lembretes.
- No n8n: Settings → API → Create API Key
- Ou: exporte o workflow de lembretes como JSON e me envie

---

## PROBLEMA 6: UX Google Calendar desconectado

### Situação atual:
IA diz "acesse totalassistente.com.br na aba Agenda" — mas o usuário não entende, não vai, e fica frustrado.

### Plano de correção:

**Opção A — Botão interativo do WhatsApp (recomendada):**
```json
{
  "type": "interactive",
  "interactive": {
    "type": "cta_url",
    "body": {
      "text": "Seu Google Calendar não está conectado. Conecte agora para sincronizar seus eventos automaticamente!"
    },
    "action": {
      "name": "cta_url",
      "parameters": {
        "display_text": "🔗 Conectar Google Calendar",
        "url": "https://totalassistente.com.br/agenda"
      }
    }
  }
}
```

**Benefício:** O botão abre direto no navegador. O usuário não precisa digitar URL.

**Opção B — Link curto na mensagem:**
- Usar a tabela `short_links` que já existe no banco
- Criar um short link tipo `totalassistente.com.br/gc` que redireciona para a página de conexão
- Mensagem: "Seu Google Calendar não está conectado. Toque aqui para conectar: totalassistente.com.br/gc"

**Opção C — Detecção proativa:**
- No workflow principal, antes de agendar evento, verificar `google_calendar_connections.is_connected`
- Se desconectado: enviar o botão/link ANTES de confirmar o agendamento
- Mensagem: "Agendei seu evento localmente, mas ele não vai aparecer no Google Calendar porque não está conectado. Quer conectar agora?"

---

## PROBLEMA 7: "Registro registrado" → Texto de receitas

### Correção simples no prompt da IA:

Trocar no system prompt:
```
Ao registrar uma ENTRADA/RECEITA, responda:
"✅ Entrada registrada!

📝 Nome: {nome}
💰 Valor: R${valor}
📂 Categoria: Renda"
```

Ao invés de "Registro registrado" usar **"Entrada registrada"**.

Categorias sugeridas para entradas:
- Salário → "Renda"
- Freelance → "Renda Extra"
- Outros → "Outros"

---

## CHECKLIST DE IMPLEMENTAÇÃO

| # | Ação | Prioridade | Complexidade | Onde |
|---|------|-----------|-------------|------|
| 1 | Botão excluir/editar ao criar evento | P0 | Média | N8N: node de envio de confirmação |
| 2 | Corrigir edição de gastos (UPDATE parcial) | P0 | Baixa | N8N: workflow de edição |
| 3 | Limitar expansão de recorrentes mensais | P0 | Média | N8N: workflow de criação |
| 4 | Verificar schedule trigger de lembretes | P0 | Baixa | N8N: workflow de lembretes |
| 5 | Atualizar prompt: remover limites de categoria | P1 | Baixa | N8N: system prompt da IA |
| 6 | Atualizar prompt: "Entrada registrada" | P1 | Baixa | N8N: system prompt da IA |
| 7 | Botão/link para conexão Google Calendar | P1 | Média | N8N: workflow principal |
| 8 | Detecção de conflito de horário | P2 | Média | N8N: workflow de agendamento |
| 9 | Timeout safety em edição (max 15s) | P2 | Baixa | N8N: workflow de edição |
| 10 | Exclusão por texto: busca mais robusta | P2 | Média | N8N: workflow de exclusão |

---

## PRÓXIMOS PASSOS

1. **Me envie a API key do n8n dev** para investigar o schedule trigger e os workflows de edição/exclusão
2. Após investigação, atualizo este plano com instruções específicas por node
3. Você aplica as correções no n8n dev
4. Eu rerodo os testes para validar
