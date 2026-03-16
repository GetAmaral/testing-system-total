# Como Instalar o Handler de Botões no n8n
**Data:** 2026-03-16

---

## O que é

Um conjunto de nodes que processa quando o user clica nos botões "Excluir" ou "Editar" que aparecem após criar um evento ou gasto.

## Payload real do WhatsApp quando user clica no botão

```json
{
  "messages": [{
    "type": "interactive",
    "interactive": {
      "type": "button_reply",
      "button_reply": {
        "id": "evt_del_1600",
        "title": "🗑️ Excluir"
      }
    }
  }]
}
```

## Como instalar

### Passo 1 — Importar os nodes

1. Abrir o workflow **Fix Conflito v2** no n8n
2. Selecionar tudo (Ctrl+A) e desselecionar (Ctrl+D) — para não mover nada
3. Clicar com botão direito no canvas → **Import from JSON**
4. Colar o conteúdo do arquivo `HANDLER-BOTOES-WORKFLOW.json`
5. Os nodes vão aparecer no canvas

### Passo 2 — Conectar ao Switch existente

O `Switch` do workflow já tem uma branch 5 chamada **"exclui/edita"** que detecta `messageType = "interactive"`. Hoje ela vai pro `Switch1` (que está vazio).

**Fazer:**
1. Desconectar `Switch` (branch "exclui/edita") → `Switch1`
2. Conectar `Switch` (branch "exclui/edita") → `Extrair Ação do Botão`
3. Pode deletar o `Switch1` (não faz nada)

### Passo 3 — Verificar credenciais

Os nodes usam 2 credenciais que já existem no seu n8n:
- **Avelum Credential** (httpBasicAuth) — para os webhooks de exclusão
- **WhatsApp Header Auth** (httpHeaderAuth) — para enviar mensagens

Se os IDs não baterem, clique em cada node e selecione a credencial correta.

### Passo 4 — Testar

1. Crie um evento: "reunião amanhã às 10h"
2. O botão "🗑️ Excluir" deve aparecer (se o ID já estiver vindo — veja seção abaixo)
3. Clique no botão
4. Deve receber: "🗑️ Evento excluído com sucesso!"

---

## Os nodes explicados

```
Switch (branch "exclui/edita")
  ↓
Extrair Ação do Botão (Code)
  → Pega o button_reply.id do payload
  → Identifica: evt_del_, fin_del_, evt_edit_, rec_del_
  → Extrai o ID numérico (ex: 1600)
  ↓
Tipo de Ação (Switch - 4 branches)
  ├── "Excluir Evento"     → Excluir Evento (Botão) → Confirmar Exclusão Evento
  ├── "Excluir Financeiro" → Excluir Financeiro (Botão) → Confirmar Exclusão Financeiro
  ├── "Editar Evento"      → Perguntar Edição Evento (envia 3 botões: Nome/Data/Ambos)
  └── "Excluir Recorrente" → Excluir Recorrente (Botão) → Confirmar Exclusão Recorrente
```

### Branch "Excluir Evento":
```
1. POST https://totalassistente.com.br/webhook/excluir-evento-total
   Body: { event_id: "1600", user_id: "uuid-do-user" }
   → Usa o MESMO webhook que já existe no sistema (exclui do Supabase + Google Calendar)

2. Envia WhatsApp: "🗑️ Evento excluído com sucesso!"
```

### Branch "Excluir Financeiro":
```
1. POST https://totalassistente.com.br/webhook/excluir-supabase
   Body: { id_gasto: "1600", id_user: "uuid-do-user" }
   → Usa o MESMO webhook que já existe

2. Envia WhatsApp: "🗑️ Registro financeiro desfeito!"
```

### Branch "Editar Evento":
```
1. Envia 3 novos botões pro WhatsApp:
   ┌───────────────┐
   │ 📝 Nome       │
   ├───────────────┤
   │ 📅 Data/Hora  │
   ├───────────────┤
   │ ✏️ Ambos      │
   └───────────────┘

2. Cada botão tem ID: edit_nome_1600, edit_data_1600, edit_ambos_1600
3. Quando o user clica, gera OUTRO clique de botão
4. Esse segundo clique pode ser tratado pelo AI Agent (manda como texto normal)
   ou por um handler adicional
```

---

## IMPORTANTE: O ID precisa vir no botão de criação

Para o handler funcionar, o botão "🗑️ Excluir" que aparece na criação do evento precisa ter o ID.

### Se o ID está vindo vazio (`evt_del_`):

Isso acontece porque o webhook `Calendar-Creator` não retorna o `evento_id_criado` na resposta HTTP.

**Correção no workflow Calendar WebHooks:**

1. Após o node `Create a row1` (caminho Google), adicionar um **Set node**:
   - Nome: `Resposta com ID`
   - Campo: `evento_id_criado` = `{{ $('sucesso_google').item.json.evento_id_criado }}`

2. Após o node `Create a row` (caminho sem Google), adicionar um **Set node**:
   - Nome: `Resposta com ID (padrao)`
   - Campo: `evento_id_criado` = `{{ $('sucesso_padrao').item.json.evento_id_criado }}`

3. No workflow Fix Conflito v2, o botão usa:
   ```javascript
   id: 'evt_del_' + String($('HTTP - Create Calendar Tool2').item.json.evento_id_criado || '')
   ```

### Para financeiro:

Inverter a ordem: primeiro registrar, depois enviar mensagem.
Então o botão usa:
```javascript
id: 'fin_del_' + String($('HTTP - Create Tool1').item.json.id || '')
```
