# Implementação — Nudge Google Calendar
**Data:** 2026-03-16
**Objetivo:** Avisar user desconectado do Google antes de buscas de agenda

---

## 1. SQL — Criar tabela gc_nudge

```sql
CREATE TABLE public.gc_nudge (
  user_id uuid primary key references profiles(id),
  last_sent_at timestamptz,
  last_response text,
  last_response_at timestamptz,
  total_nao integer default 0,
  opted_out boolean default false
);
```

---

## 2. Onde colocar no Fix Conflito v2

No fluxo de busca de agenda (branches `prompt_editar1`, `prompt_excluir`, e quando o AI Agent chama `buscar_eventos`), ANTES de executar a busca.

O ponto mais fácil: logo após o `Switch - Branches1` nas branches de agenda, antes dos prompts.

```
Switch - Branches1 (branch agenda)
  ↓
[NOVO] Supabase: GET profiles (google_connect_status)
  ↓
[NOVO] IF google_connect_status = false
  ↓ TRUE                          ↓ FALSE
[NOVO] Supabase: GET gc_nudge     → continua fluxo normal
  ↓
[NOVO] IF pode enviar?
  ↓ TRUE              ↓ FALSE
[NOVO] Enviar botão   → continua fluxo normal
[NOVO] UPSERT gc_nudge
  ↓
continua fluxo normal
```

---

## 3. Nodes a criar (6 nodes)

### Node 1: `Checar Google Connect`
**Tipo:** Supabase (Get)
```
Tabela: profiles
Filtro: id = {{ $('setar_user').item.json.id_user }}
Select: google_connect_status
```

### Node 2: `IF Google Desconectado`
**Tipo:** IF
```
Condição: {{ $json.google_connect_status }} is false
TRUE → Node 3
FALSE → continua fluxo normal
```

### Node 3: `Buscar Nudge`
**Tipo:** Supabase (Get)
```
Tabela: gc_nudge
Filtro: user_id = {{ $('setar_user').item.json.id_user }}
alwaysOutputData: true (retorna vazio se não existir)
```

### Node 4: `Pode Enviar Nudge?`
**Tipo:** IF
```
Condição:
={{ (() => {
  const n = $json;
  if (!n || !n.user_id) return true;
  if (n.opted_out) return false;
  const now = Date.now();
  if (n.last_sent_at && (now - new Date(n.last_sent_at).getTime()) < 3 * 86400000) return false;
  if (n.last_response === 'nao' && n.last_response_at && (now - new Date(n.last_response_at).getTime()) < 7 * 86400000) return false;
  return true;
})() }}

Operador: is true
TRUE → Node 5
FALSE → continua fluxo normal
```

### Node 5: `Enviar Nudge Google`
**Tipo:** HTTP Request
```
POST https://graph.facebook.com/v23.0/744582292082931/messages

Body:
={{
{
  messaging_product: 'whatsapp',
  to: $('Evolution API- Take all').item.json.phone,
  type: 'interactive',
  interactive: {
    type: 'button',
    body: {
      text: '📅 Vi que seu Google Calendar não está conectado.\n\nConectando, seus eventos aparecem automaticamente no app do Google Agenda!\n\nQuer conectar agora?'
    },
    action: {
      buttons: [
        {
          type: 'reply',
          reply: { id: 'gc_sim', title: '✅ Sim, conectar' }
        },
        {
          type: 'reply',
          reply: { id: 'gc_nao', title: '❌ Agora não' }
        }
      ]
    }
  }
}
}}

Credencial: WhatsApp Header Auth
```

### Node 6: `Registrar Nudge Enviado`
**Tipo:** Supabase (Upsert) ou HTTP Request para Supabase REST
```
POST https://ldbdtakddxznfridsarn.supabase.co/rest/v1/gc_nudge
Header: Prefer: resolution=merge-duplicates

Body:
{
  "user_id": "{{ $('setar_user').item.json.id_user }}",
  "last_sent_at": "{{ $now }}"
}
```

Depois → continua fluxo normal de busca.

---

## 4. Handler dos botões gc_sim / gc_nao

No `Extrair Botão` (Set node), o `buttonId` já captura `gc_sim` e `gc_nao`.

No `Tipo de Ação` (Switch), adicionar 2 branches:

### Condição nova: `{{ $json.buttonId }}` **equals** `gc_sim`

**Fluxo:**
```
1. Supabase: UPSERT gc_nudge
   {
     "user_id": user_id,
     "last_response": "sim",
     "last_response_at": NOW()
   }

2. HTTP Request (WhatsApp): Enviar tutorial com botão CTA
```

```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('Extrair Botão').item.json.user_phone,
  type: 'interactive',
  interactive: {
    type: 'cta_url',
    body: {
      text: '🎉 Ótimo! É bem simples:\n\n1️⃣ Toque no botão abaixo\n2️⃣ Faça login com sua conta Google\n3️⃣ Autorize o acesso ao calendário\n4️⃣ Pronto!\n\nDepois de conectar, tudo que criar aqui aparece no Google Agenda automaticamente.'
    },
    action: {
      name: 'cta_url',
      parameters: {
        display_text: '🔗 Conectar meu Google',
        url: 'https://totalassistente.com.br/agenda'
      }
    }
  }
}
}}
```

### Condição nova: `{{ $json.buttonId }}` **equals** `gc_nao`

**Fluxo:**
```
1. Supabase: HTTP Request (PATCH)
   PATCH https://ldbdtakddxznfridsarn.supabase.co/rest/v1/gc_nudge?user_id=eq.USER_ID

   Body:
   {
     "last_response": "nao",
     "last_response_at": "NOW()",
     "total_nao": {{ $json.total_nao + 1 }},
     "opted_out": {{ ($json.total_nao + 1) >= 2 }}
   }

   (Ou usar RPC para incrementar atomicamente)

2. HTTP Request (WhatsApp):
```

```javascript
={{
{
  messaging_product: 'whatsapp',
  to: $('Extrair Botão').item.json.user_phone,
  type: 'text',
  text: {
    body: 'Sem problemas! Seus eventos continuam salvos aqui normalmente. Se mudar de ideia, é só me dizer "conectar google".'
  }
}
}}
```

---

## 5. Regras resumidas

| Situação | Ação |
|----------|------|
| `google_connect_status = true` | Não faz nada |
| Nunca recebeu nudge | Envia |
| Recebeu há < 3 dias | Não envia |
| Clicou "não" há < 7 dias | Não envia |
| Clicou "não" 2x total | Nunca mais envia (`opted_out = true`) |
| Clicou "sim" | Envia tutorial + link |

---

## 6. No Switch "Tipo de Ação" — novas condições

Adicionar ao Switch que roteia botões:

| Branch | Condição |
|--------|----------|
| (existentes) | evt_del_, fin_del_, evt_edit_, rec_del_ |
| **Google Sim** | `{{ $json.buttonId }}` equals `gc_sim` |
| **Google Não** | `{{ $json.buttonId }}` equals `gc_nao` |
