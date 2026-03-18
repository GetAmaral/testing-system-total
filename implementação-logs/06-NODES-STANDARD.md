# Nós a Adicionar no Standard - User Standard - Total

**Workflow ID:** c8gtSmh1BPzZXbJa
**Objetivo:** Adicionar logging COMPLETO (hoje é ZERO)

---

## Situação Atual

O workflow Standard **NÃO possui NENHUM nó de log**. Toda conversa com usuários do plano Standard é perdida após o TTL do Redis (1 hora).

Os nós a adicionar seguem o mesmo padrão do Premium, mas são TODOS novos.

---

## Nó 1: Log de Classificação

**Onde inserir:** Após o nó `Escolher Branch`, ANTES do `Switch - Branches1`, em PARALELO.

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
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_message: $json.mensagem_acumulada || null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output, source_workflow: 'standard', event_type: 'classification', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 2: Log de Resposta IA Completa

**Onde inserir:** Após o nó `Code in JavaScript` (parse), ANTES do `Switch2`, em PARALELO.

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
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_plan: 'standard', user_message: $('Merge1').item.json.mensagem || null, ai_message: $json.parsed_output ? $json.parsed_output.mensagem : null, ai_action: $json.parsed_output ? $json.parsed_output.acao : null, ai_tools_called: $json.parsed_output ? $json.parsed_output.tool : null, ai_full_response: $json.parsed_output || null, source_workflow: 'standard', event_type: 'ai_response', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 3: Log de Ações Executadas

**Onde inserir:** Após CADA nó de ação HTTP, em PARALELO. O Standard tem os seguintes nós de ação:

| Nó de Ação | action_type |
|-----------|-------------|
| HTTP - Create Tool | registrar_financeiro |
| HTTP - Create Tool1 | editar_financeiro |
| HTTP - Create Tool2 | excluir_financeiro |
| HTTP - Create Tool3 | buscar_financeiro |
| HTTP - Create Calendar Tool | criar_evento |
| HTTP - Create Calendar Tool1 | editar_evento |
| HTTP - Create Calendar Tool2 | excluir_evento |
| HTTP - Create Calendar Tool3 | buscar_evento |

**Modelo para CADA nó de ação:**

```json
{
  "name": "LOG: Ação {NOME}",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, action_type: '{ACTION_TYPE}', action_input: $json.body || null, action_output: $json || null, action_success: true, source_workflow: 'standard', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

> Substituir `{NOME}` e `{ACTION_TYPE}` conforme a tabela acima.

---

## Nó 4: Log de Extração de Documento

**Onde inserir:** Após os nós `PDF Extractor` e `HTTP Request8` (extração de imagem).

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
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, message_type: 'document', extracted_data: $json, source_workflow: 'standard', event_type: 'ai_response', metadata: { extraction_type: 'pdf' }, message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 5: Log de Consolidação (NOVO — não existia!)

**Onde inserir:** Este é o nó MAIS CRÍTICO para o Standard. Hoje o Standard não salva NADA. Este nó deve ser adicionado no FINAL do fluxo, após o envio da mensagem WhatsApp.

**Identificar o ponto final:** No Standard, após o `Switch2` cada branch termina enviando mensagem via WhatsApp (`Send message`, `Send message1`, `Send message2`, etc.) ou via HTTP (`HTTP Request — send text`, `HTTP Request — Basic Template`, etc.).

**Estratégia:** Adicionar o nó de consolidação APÓS cada ponto final de envio de mensagem.

**Para os nós que enviam via HTTP Request (send text):**

```json
{
  "name": "LOG: Consolidação",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_APÓS_SEND],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_email: $('setar_user').item.json.user_email || null, user_plan: 'standard', user_message: $('Merge1').item.json.mensagem || null, message_type: $('setar_user').item.json.messageType || $('Evolution API').item.json.messageType || 'text', ai_message: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.mensagem : null, ai_action: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.acao : null, ai_tools_called: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.tool : null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output || null, source_workflow: 'standard', event_type: 'interaction_complete', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Resumo dos Nós Adicionados ao Standard

| Nó | event_type | Dados capturados | Prioridade |
|----|-----------|------------------|-----------|
| LOG: Classificação | classification | branch, user_message | ALTA |
| LOG: Resposta IA | ai_response | ai_action, ai_tools_called, ai_full_response | CRÍTICA |
| LOG: Ação {tipo} (x8) | action_executed | action_type, action_input/output | ALTA |
| LOG: Extração Doc | ai_response | extracted_data | MÉDIA |
| LOG: Consolidação | interaction_complete | TUDO consolidado | CRÍTICA |

**Total: ~12 nós HTTP Request com continueOnFail=true**

---

## Impacto

Antes: **0% das conversas Standard persistidas**
Depois: **100% das conversas Standard persistidas com contexto completo**
