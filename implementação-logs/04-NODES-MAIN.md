# Nós a Adicionar no Main - Total Assistente

**Workflow ID:** 9WDlyel5xRCLAvtH
**Objetivo:** Capturar transcrição de áudio, resumo e roteamento

---

## Variáveis Necessárias

O webhook de log será acessível em:
```
https://n8n.totalassistente.com.br/webhook/execution-log
```

> **NOTA:** Após criar e ativar o workflow "Execution Log", confirme a URL exata do webhook. O path é `execution-log` mas o domínio pode variar dependendo de como o N8N está configurado (pode ser `totalassistente.com.br/webhook/execution-log`).

---

## Nó 1: Log de Transcrição de Áudio

**Onde inserir:** Após o nó `Redis` (SET transcricao:{wa_id}), em PARALELO (não sequencial).

**Conexão:**
```
[Transcribe a recording] → [Redis SET] → (continua fluxo normal)
                                        ↘ [LOG: Transcrição] (paralelo, sem bloquear)
```

**Configuração do nó HTTP Request:**

```json
{
  "name": "LOG: Transcrição",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO_DO_REDIS],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('trigger-whatsapp').item.json.entry[0].changes[0].value.contacts[0].wa_id, user_id: $('setar_user').item.json.user_id || null, user_name: $('setar_user').item.json.user_name || null, user_message: '[AUDIO]', message_type: 'audio', transcription_text: $('Transcribe a recording').item.json.text, source_workflow: 'main', event_type: 'transcription', message_timestamp: new Date().toISOString() }) }}",
    "options": {
      "timeout": 5000,
      "batching": { "batch": { "batchSize": 1, "batchInterval": 0 } }
    }
  },
  "continueOnFail": true
}
```

**IMPORTANTE:** `continueOnFail: true` — se o log falhar, o fluxo principal não é afetado.

---

## Nó 2: Log de Resumo de Áudio

**Onde inserir:** Após o nó `Message a model` (que gera o resumo), em PARALELO com o `Send message5` (que envia o resumo ao usuário).

**Conexão:**
```
[Message a model] → [Send message5 (WhatsApp)] (continua normal)
                   ↘ [LOG: Resumo Áudio] (paralelo)
```

**Configuração:**

```json
{
  "name": "LOG: Resumo Áudio",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('trigger-whatsapp').item.json.entry[0].changes[0].value.contacts[0].wa_id, user_id: $('setar_user').item.json.user_id || null, user_name: $('setar_user').item.json.user_name || null, transcription_text: $('Redis1').item.json.data, summary_text: $('Message a model').item.json.message.content, source_workflow: 'main', event_type: 'audio_summary', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Nó 3: Log de Roteamento (Premium/Standard)

**Onde inserir:** Após o nó `Premium User` (HTTP Request que envia dados ao workflow Premium), em PARALELO.

**Conexão:**
```
[Premium User] → (continua normal)
               ↘ [LOG: Roteamento] (paralelo)
```

**Configuração:**

```json
{
  "name": "LOG: Roteamento",
  "type": "n8n-nodes-base.httpRequest",
  "typeVersion": 4.2,
  "position": [POSICIONAR_ABAIXO],
  "parameters": {
    "method": "POST",
    "url": "https://n8n.totalassistente.com.br/webhook/execution-log",
    "sendBody": true,
    "specifyBody": "json",
    "jsonBody": "={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone, user_id: $('setar_user').item.json.user_id, user_name: $('setar_user').item.json.user_name, user_email: $('setar_user').item.json.user_email || null, user_plan: $('If3').item.json.plan_type || 'unknown', user_message: $('setar_user').item.json.conversation, message_type: $('setar_user').item.json.messageType || 'text', message_id: $('setar_user').item.json.messageId || null, source_workflow: 'main', event_type: 'message_routed', routed_to: $('If3').item.json.plan_type === 'premium' ? 'premium' : 'standard', message_timestamp: new Date().toISOString() }) }}",
    "options": { "timeout": 5000 }
  },
  "continueOnFail": true
}
```

---

## Resumo dos Nós Adicionados ao Main

| Nó | event_type | Dados capturados | Posição |
|----|-----------|------------------|---------|
| LOG: Transcrição | transcription | user_phone, transcription_text, message_type=audio | Após Redis SET |
| LOG: Resumo Áudio | audio_summary | transcription_text, summary_text | Após Message a model |
| LOG: Roteamento | message_routed | user_*, message_type, routed_to, user_plan | Após Premium User |

**Total: 3 nós HTTP Request com continueOnFail=true**
