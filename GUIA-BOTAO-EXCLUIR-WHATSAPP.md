# Guia: Botão de Excluir no WhatsApp — Passo a Passo
**Data:** 2026-03-15

---

## Como funciona o botão no WhatsApp

Existem **2 tipos de mensagem** no WhatsApp Business:

### Tipo 1 — Template (o que você usa hoje)
- Precisa criar no Meta Business Suite e esperar aprovação
- Usado para enviar mensagens **fora da janela de 24h**
- Exemplo: o template `novo_evento_do_usuario` que você já tem

### Tipo 2 — Mensagem Interativa (o que vamos usar)
- **NÃO precisa criar template**
- **NÃO precisa aprovação do Meta**
- Funciona **dentro da janela de 24h** (e no nosso caso funciona, porque o user acabou de mandar mensagem)
- O botão é gerado na hora, pelo JSON que você envia na API

---

## Fluxo visual

### HOJE — o que acontece quando cria um evento:

```
User: "dentista amanhã às 14h"

n8n → WhatsApp API (template):
  "✅ Evento agendado! Dentista 16/03 às 14:00"

User vê: mensagem de texto normal, sem ação
```

### DEPOIS — com o botão:

```
User: "dentista amanhã às 14h"

n8n → WhatsApp API (interactive):
  ┌─────────────────────────────────┐
  │ ✅ Evento agendado!             │
  │ 📅 Dentista                     │
  │ ⏰ 16/03 às 14:00               │
  │                                 │
  │  ┌───────────────┐              │
  │  │ 🗑️ Excluir    │              │
  │  └───────────────┘              │
  └─────────────────────────────────┘

User clica "🗑️ Excluir"

WhatsApp manda de volta pro webhook:
  { "button_reply": { "id": "evt_del_abc123-uuid-do-evento" } }

n8n recebe → DELETE FROM calendar WHERE uuid = 'abc123...'
  → Responde: "🗑️ Evento excluído!"
```

---

## O que muda no n8n — 2 alterações

### Alteração 1: Trocar o envio da confirmação

**ONDE:** Workflow `Calendar WebHooks`, o node `HTTP Request` que hoje envia o template `novo_evento_do_usuario`.

**HOJE** ele envia:
```json
{
  "messaging_product": "whatsapp",
  "to": "554391936205",
  "type": "template",
  "template": {
    "name": "novo_evento_do_usuario",
    "language": { "code": "pt_BR" },
    "components": [
      {
        "type": "body",
        "parameters": [
          { "type": "text", "text": "NOME_EVENTO" },
          { "type": "text", "text": "DATA_FORMATADA" }
        ]
      }
    ]
  }
}
```

**TROCAR POR:**
```json
{
  "messaging_product": "whatsapp",
  "to": "554391936205",
  "type": "interactive",
  "interactive": {
    "type": "button",
    "body": {
      "text": "✅ Evento agendado!\n📅 Dentista\n⏰ 16/03 às 14:00"
    },
    "action": {
      "buttons": [
        {
          "type": "reply",
          "reply": {
            "id": "evt_del_UUID_DO_EVENTO_AQUI",
            "title": "🗑️ Excluir"
          }
        }
      ]
    }
  }
}
```

A única diferença é `"type": "interactive"` ao invés de `"type": "template"`. O botão vem no campo `action.buttons`. O WhatsApp renderiza automaticamente.

**No n8n, o body JSON do HTTP Request ficaria:**
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

### Alteração 2: Capturar o clique do botão

**ONDE:** Workflow `Fix Conflito v2`, logo depois do node `Evolution API- Take all`.

Quando o user clica no botão, o WhatsApp envia uma mensagem pro webhook. Essa mensagem é diferente de uma mensagem de texto normal. Vem assim:

```json
{
  "messageType": "interactiveMessage",
  "conversation": "evt_del_abc123-uuid-do-evento"
}
```

Adicionar um **IF node** logo no início:

```
SE conversation começa com "evt_del_" →
  1. Extrair UUID (tirar o prefixo "evt_del_")
  2. DELETE no Supabase: WHERE uuid = UUID
  3. Se Google conectado: DELETE no Google Calendar
  4. Responder: "🗑️ Evento excluído!"

SENÃO →
  Continuar fluxo normal (AI Agent)
```

---

## Perguntas e respostas

| Pergunta | Resposta |
|----------|---------|
| Precisa criar template? | **NÃO** |
| Precisa aprovação do Meta? | **NÃO** |
| Funciona dentro da janela 24h? | **SIM** (e o user acabou de mandar mensagem, então está dentro) |
| Funciona fora da janela 24h? | **NÃO** — mas não é o caso, porque o botão só aparece como resposta |
| Quantos botões posso colocar? | Até **3** (pode ter Excluir + Editar + outro) |
| O que muda no n8n? | **2 coisas**: trocar envio de template por interactive + capturar o clique |

---

## Opcional: Adicionar botão de Editar também

Pode ter até 3 botões na mesma mensagem:

```json
{
  "action": {
    "buttons": [
      {
        "type": "reply",
        "reply": {
          "id": "evt_del_UUID",
          "title": "🗑️ Excluir"
        }
      },
      {
        "type": "reply",
        "reply": {
          "id": "evt_edit_UUID",
          "title": "✏️ Editar"
        }
      }
    ]
  }
}
```

Quando user clica "✏️ Editar":
- Responder: "O que quer mudar? (nome, data/hora, ou ambos)"
- Guardar o UUID na conversa
- Próxima mensagem do user → fazer UPDATE direto pelo UUID (sem busca, sem ambiguidade)
