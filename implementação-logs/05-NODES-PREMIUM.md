# Nós a Adicionar no Premium - Fix Conflito v2

**Workflow ID:** tyJ3YAAtSg1UurFj
**Objetivo:** Capturar classificação, resposta IA completa, ações executadas e consolidação

---

## Contexto do Workflow

O fluxo do Premium é:
```
webhook(premium) → debounce Redis → Escolher Branch → Switch-Branches1
  → [branch específico: prompt_criar1, prompt_busca1, etc.]
  → AI Agent → Code in JavaScript (parse) → Switch2 (acao)
  → [HTTP Create Tool / Calendar Tool / etc.]
  → formatacao_mensagem → Send message (WhatsApp)
  → Get a row (profiles) → Create a row1 (log_users_messages) ← LOG ATUAL
```

---

## Nó 1: Log de Classificação

**Onde inserir:** Após o nó `Escolher Branch`, ANTES do `Switch - Branches1`, em PARALELO.

**Conexão:**
```
[Escolher Branch] → [Switch - Branches1] (continua normal)
                  ↘ [LOG: Classificação] (paralelo)
```

**Configuração:**

```json
{
  "name": "LOG: Classificação",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO_DO_ESCOLHER_BRANCH],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_message: $('Merge1').item.json.mensagem || $json.mensagem_acumulada, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output, source_workflow: 'premium', event_type: 'classification', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 2: Log de Resposta IA Completa

**Onde inserir:** Após o nó `Code in JavaScript` (que faz parse do output do AI Agent), ANTES do `Switch2`, em PARALELO.

Este é o nó MAIS IMPORTANTE — captura o JSON completo da IA incluindo `acao`, `tool` e `mensagem`.

**Conexão:**
```
[Code in JavaScript] → [Switch2] (continua normal)
                     ↘ [LOG: Resposta IA] (paralelo)
```

**Configuração:**

```json
{
  "name": "LOG: Resposta IA",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO_DO_CODE_IN_JAVASCRIPT],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_email: $('setar_user').item.json.user_email || null, user_plan: 'premium', user_message: $('Merge1').item.json.mensagem || null, ai_message: $json.parsed_output ? $json.parsed_output.mensagem : null, ai_action: $json.parsed_output ? $json.parsed_output.acao : null, ai_tools_called: $json.parsed_output ? $json.parsed_output.tool : null, ai_full_response: $json.parsed_output || null, source_workflow: 'premium', event_type: 'ai_response', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 3: Log de Ação Executada (Financeiro)

**Onde inserir:** Após cada nó `HTTP - Create Tool` (que executa a ação), em PARALELO.

Existem MÚLTIPLOS nós de ação no Premium. Os principais são:
- `HTTP - Create Tool` (registrar financeiro)
- `HTTP - Create Tool1` (outro tipo)
- `HTTP - Create Tool2` (outro tipo)
- `HTTP - Create Calendar Tool` (criar evento)
- `HTTP - Create Calendar Tool2` a `6` (variantes de agenda)

**Para o nó principal (`HTTP - Create Tool`):**

```json
{
  "name": "LOG: Ação Financeiro",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, action_type: 'registrar_financeiro', action_input: $('HTTP - Create Tool').item.json.body || null, action_output: $('HTTP - Create Tool').item.json || null, action_success: $('HTTP - Create Tool').item.json.statusCode ? $('HTTP - Create Tool').item.json.statusCode < 400 : true, source_workflow: 'premium', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

**Para `HTTP - Create Calendar Tool`:**

```json
{
  "name": "LOG: Ação Agenda",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, action_type: 'criar_evento', action_input: $('HTTP - Create Calendar Tool').item.json.body || null, action_output: $('HTTP - Create Calendar Tool').item.json || null, action_success: true, source_workflow: 'premium', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

> **NOTA:** Replicar este padrão para CADA nó de ação (Create Tool1, Create Tool2, Calendar Tool2-6), ajustando `action_type` conforme a ação.

---

## Nó 4: Log de Extração de Documento

**Onde inserir:** Após os nós de extração de PDF/imagem (PDF Extractor, HTTP Request8), em PARALELO.

```json
{
  "name": "LOG: Extração Doc",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, message_type: 'document', extracted_data: $json, source_workflow: 'premium', event_type: 'ai_response', metadata: { extraction_type: 'pdf' }, message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 5: Log de Consolidação (interaction_complete)

**Onde inserir:** APÓS o nó `Create a row1` existente (que já salva em log_users_messages), em SEQUÊNCIA.

Este nó consolida TODOS os dados da interação em um único registro.

**Conexão:**
```
[Create a row1 (log_users_messages)] → [LOG: Consolidação] (sequencial)
```

**Configuração:**

```json
{
  "name": "LOG: Consolidação",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_APÓS_CREATE_A_ROW1],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_email: $('Get a row').item.json.email || null, user_plan: 'premium', user_message: $('Merge1').item.json.mensagem || null, message_type: $('setar_user').item.json.messageType || $('Evolution API').item.json.messageType || 'text', ai_message: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.mensagem : null, ai_action: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.acao : null, ai_tools_called: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.tool : null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output || null, source_workflow: 'premium', event_type: 'interaction_complete', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Resumo dos Nós Adicionados ao Premium

| Nó | event_type | Dados capturados | Posição |
|----|-----------|------------------|---------|
| LOG: Classificação | classification | branch, user_message | Após Escolher Branch |
| LOG: Resposta IA | ai_response | ai_action, ai_tools_called, ai_full_response, ai_message | Após Code in JavaScript |
| LOG: Ação Financeiro | action_executed | action_type, action_input, action_output | Após HTTP Create Tool |
| LOG: Ação Agenda | action_executed | action_type, action_input, action_output | Após HTTP Create Calendar Tool |
| LOG: Extração Doc | ai_response | extracted_data, message_type=document | Após PDF Extractor |
| LOG: Consolidação | interaction_complete | TUDO consolidado | Após Create a row1 |

**Total: 6+ nós HTTP Request com continueOnFail=true**

> **NOTA:** Para cada variante de `HTTP - Create Tool` e `HTTP - Create Calendar Tool` (existem ~8 variantes), replicar o padrão do LOG: Ação ajustando o `action_type`.
