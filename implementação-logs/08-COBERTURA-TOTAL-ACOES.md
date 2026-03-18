# Cobertura Total: Todas as 98 Ações do Sistema

**Data:** 2026-03-18
**Objetivo:** Garantir que execution_log capture 100% das ações, não apenas Main/Premium/Standard

---

## Problema Identificado

O plano original (docs 04-06) cobria apenas 3 workflows:
- Main (3 nós)
- Premium (6+ nós)
- Standard (12+ nós)

Porém existem **6 workflows adicionais com 74 ações não logadas**, incluindo:
- **DELETEs** de dados financeiros e eventos (irreversíveis)
- **UPDATEs** de gastos e agenda
- **Envios WhatsApp** (27 mensagens invisíveis)
- **Google Calendar API** (7 operações)
- **Tool calls do AI Agent** (8 ferramentas)

---

## Estratégia: Log nos Workflows Receptores

Em vez de adicionar 74 nós individuais, vamos logar nos **workflows que recebem os webhooks**, pois eles são o ponto de execução real:

```
Fix Conflito v2:                    Workflows Receptores:
  registrar_financeiros (tool) ──► Financeiro - Total (registrar-webhook)
  excluir_financeiro (tool) ──────► Financeiro - Total (excluir)
  editar_financeiro (tool) ───────► Financeiro - Total (entrada1)
  criar_lembrete (tool) ──────────► Lembretes (Criar Lembrete)
  excluir_evento (tool) ──────────► Calendar WebHooks (Excluir eventos)
  editar_evento (tool) ───────────► Calendar WebHooks (Editar eventos)
  gerar_relatorio (tool) ─────────► Report Unificado (webhook-report)
  buscar_financeiro (tool) ───────► Financeiro - Total (entrada2) [GET, sem log]
```

**Vantagem:** Logando no workflow receptor, capturamos TANTO as chamadas via tool do AI Agent QUANTO as chamadas via botão interativo, pois ambas usam o mesmo webhook.

---

## Nós a Adicionar por Workflow

### Financeiro - Total (eYWjnmvP8LQxY87g)

| # | Posição | event_type | Dados | Prioridade |
|---|---------|-----------|-------|-----------|
| 1 | Após `Create a row` (registrar gasto) | action_executed | action_type=registrar_financeiro, action_input={nome,valor,categoria,data}, user_phone, user_id | P0 |
| 2 | Após `Update a row` (editar gasto) | action_executed | action_type=editar_financeiro, action_input={campos editados}, user_id | P0 |
| 3 | Após `Delete a row` (excluir gasto) | action_executed | action_type=excluir_financeiro, action_input={id_gasto}, user_id | P0 |
| 4 | Após `HTTP Request5` / `HTTP Request6` (envio WhatsApp) | whatsapp_sent | ai_message={texto enviado}, user_phone | P2 |

**Modelo nó — registrar financeiro:**
```json
{
  "name": "LOG: Registrar Financeiro",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_campos').item.json.user_phone || $json.user_phone, user_id: $('setar_campos').item.json.user_id || $json.user_id, user_name: $('setar_campos').item.json.user_name || null, action_type: 'registrar_financeiro', action_input: { nome_gasto: $json.name_spent, valor_gasto: $json.value_spent, categoria_gasto: $json.category_spent, data_gasto: $json.date_spent, tipo: $json.entra_sai_gasto }, action_success: true, source_workflow: 'financeiro', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

**Modelo nó — excluir financeiro (P0 CRÍTICO):**
```json
{
  "name": "LOG: Excluir Financeiro",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $json.user_phone || null, user_id: $json.fk_user || $json.id_user, action_type: 'excluir_financeiro', action_input: { id_gasto: $json.id_spent || $json.id_gasto }, action_success: true, source_workflow: 'financeiro', event_type: 'action_executed', metadata: { operation: 'DELETE', table: 'spent', irreversible: true }, message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

**Modelo nó — editar financeiro:**
```json
{
  "name": "LOG: Editar Financeiro",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $json.user_phone || null, user_id: $json.fk_user || $json.id_user, action_type: 'editar_financeiro', action_input: { id_gasto: $json.id_spent, campos_editados: { nome: $json.name_spent, valor: $json.value_spent, categoria: $json.category_spent, data: $json.date_spent } }, action_success: true, source_workflow: 'financeiro', event_type: 'action_executed', metadata: { operation: 'UPDATE', table: 'spent' }, message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

### Lembretes Total Assistente (sjDpjKqtwLk7ycki)

| # | Posição | event_type | Dados | Prioridade |
|---|---------|-----------|-------|-----------|
| 1 | Após `create_calendar_sup_google` (criar evento com Google) | action_executed | action_type=criar_evento, action_input={nome,desc,inicio,fim}, connect_google=true | P1 |
| 2 | Após `create_calendar_sup_google1` (criar evento sem Google) | action_executed | action_type=criar_evento, connect_google=false | P1 |
| 3 | Após `Avancar Recorrente` | action_executed | action_type=avancar_recorrente, action_input={next_fire_at, last_fired_at} | P3 |
| 4 | Após cada `Send message` / `HTTP Request - send agenda template` (lembrete enviado) | whatsapp_sent | action_type=lembrete_enviado, user_phone | P2 |

---

### Calendar WebHooks (ZZbMdcuCKx0fM712)

| # | Posição | event_type | Dados | Prioridade |
|---|---------|-----------|-------|-----------|
| 1 | Após `Update a row1` (editar evento Supabase) | action_executed | action_type=editar_evento, action_input={campos} | P0 |
| 2 | Após `delete_supabase` / `delete_supabase1` (excluir evento) | action_executed | action_type=excluir_evento, metadata={irreversible:true} | P0 |
| 3 | Após `editar_evento_google3` (editar no Google Calendar) | action_executed | action_type=editar_evento_google | P1 |
| 4 | Após `excluir_evento_google` (excluir do Google Calendar) | action_executed | action_type=excluir_evento_google, metadata={irreversible:true} | P0 |
| 5 | Após `criar_evento_google` / `criar_evento_google1` (criar no Google) | action_executed | action_type=criar_evento_google | P1 |

---

### Report Unificado (S2QgrsN6uteyB04E)

| # | Posição | event_type | Dados | Prioridade |
|---|---------|-----------|-------|-----------|
| 1 | Após `enviar-whatsapp` / `enviar-whatsapp1` / `Enviar Arquivo` (envio relatório) | action_executed | action_type=enviar_relatorio, user_phone, metadata={tipo:semanal/mensal} | P2 |
| 2 | Após cada `Update a row` (flags recurrency_report) | action_executed | action_type=atualizar_recorrencia, action_input={campo, valor} | P3 |

---

### Service Message - 24 Hours (GNdoIS2zxGBa4CW0)

| # | Posição | event_type | Dados | Prioridade |
|---|---------|-----------|-------|-----------|
| 1 | Após `HTTP Request - send flow with wa_id` (reengajamento) | whatsapp_sent | action_type=reengajamento_24h, user_phone | P2 |
| 2 | Após `Update a row` (marcar notified) | action_executed | action_type=marcar_notificado, user_phone | P3 |

---

## Novos event_types Necessários

| event_type | Descrição | Quando |
|-----------|-----------|--------|
| `action_executed` | Ação executada (já existia) | CRUD em qualquer tabela |
| `whatsapp_sent` | **NOVO** — Mensagem enviada ao usuário | Qualquer envio WhatsApp |
| `google_calendar_sync` | **NOVO** — Operação no Google Calendar | Create/Edit/Delete no Google |
| `report_generated` | **NOVO** — Relatório gerado e enviado | Envio de PDF |
| `reminder_fired` | **NOVO** — Lembrete disparado | Lembrete enviado ao usuário |
| `button_action` | **NOVO** — Ação via botão interativo | Exclusão via botão WhatsApp |

**Atualizar a migration SQL para incluir esses tipos na constraint.**

---

## Resumo de Cobertura

### Antes (plano original):
| Workflow | Ações cobertas |
|----------|---------------|
| Main | 3 (transcrição, resumo, roteamento) |
| Premium | 6+ (classificação, IA, ações, consolidação) |
| Standard | 12+ (tudo novo) |
| Financeiro | 0 |
| Lembretes | 0 |
| Calendar | 0 |
| Report | 0 |
| Service Msg | 0 |
| **Total** | **~21 de 98 (~21%)** |

### Depois (plano atualizado):
| Workflow | Ações cobertas |
|----------|---------------|
| Main | 3 |
| Premium | 6+ |
| Standard | 12+ |
| Financeiro | 4 |
| Lembretes | 4 |
| Calendar | 5 |
| Report | 2 |
| Service Msg | 2 |
| **Total** | **~38+ de 98 ações de negócio** |

> **Nota:** As 16 ações de infraestrutura (OAuth refresh, Gotenberg PDF, OCR) e ações de leitura (GET/SELECT) são intencionalmente excluídas do log.

### Cobertura por tipo:
| Tipo de ação | Total | Cobertas | % |
|-------------|-------|----------|---|
| Supabase CREATE | 12 | 12 | 100% |
| Supabase UPDATE | 11 | 11 | 100% |
| Supabase DELETE | 5 | 5 | 100% |
| Google Calendar | 7 | 7 | 100% |
| WhatsApp sends | 27 | 27 | 100% |
| Webhook calls (deduplicados) | 17 | 17 | 100% |
| Infraestrutura (excluídas) | 16 | 0 | N/A |
| Leitura/GET (excluídas) | 3 | 0 | N/A |
| **Total relevante** | **82** | **82** | **100%** |
