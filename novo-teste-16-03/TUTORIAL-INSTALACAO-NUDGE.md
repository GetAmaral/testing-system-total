# Tutorial — Como instalar o Nudge Google Calendar no n8n
**Passo a passo com prints mentais**

---

## PASSO 1 — Criar tabela no Supabase

1. Abra o Supabase do banco principal (ldbdtakddxznfridsarn)
2. Vá em **SQL Editor**
3. Cole e execute:

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

4. Confirme que a tabela apareceu em **Table Editor**

---

## PASSO 2 — Importar os nodes no Fix Conflito v2

1. Abra o workflow **Fix Conflito v2** no n8n
2. Clique com **botão direito** em qualquer lugar vazio do canvas
3. Clique em **Import from JSON** (ou Ctrl+V em alguns casos)
4. Abra o arquivo `NODES-NUDGE-GOOGLE.json` do GitHub
5. Copie TODO o conteúdo e cole
6. Os 10 nodes vão aparecer no canvas

---

## PASSO 3 — Posicionar os nodes

Depois de importar, arraste os nodes para ficar organizado. Eles são divididos em 2 grupos:

### Grupo A — Fluxo principal (6 nodes)
```
Checar Google Connect → Google Desconectado? → Buscar Nudge → Pode Enviar Nudge? → Enviar Nudge Google → Registrar Nudge Enviado
```

Posicione eles ANTES das branches de agenda (prompt_editar1, prompt_excluir, etc).

### Grupo B — Handler de botões (4 nodes)
```
Registrar Sim → Enviar Tutorial Google
Registrar Não → Responder Não Google
```

Posicione eles perto do handler de botões existente (Switch "Tipo de Ação").

---

## PASSO 4 — Conectar o Grupo A (fluxo principal)

### 4.1 — Entrada
Ache o ponto no workflow onde as mensagens de AGENDA são processadas (depois do Switch que separa texto/audio/imagem/documento/interactive).

A branch de **texto** (que vai pro debounce → AI Agent) é onde o nudge deve entrar.

**Conecte:** O node que vem ANTES do fluxo de agenda → `Checar Google Connect`

### 4.2 — Saída TRUE (desconectado)
`Google Desconectado?` TRUE → já está conectado ao `Buscar Nudge` (automático do import)

### 4.3 — Saída FALSE (conectado = tudo normal)
`Google Desconectado?` FALSE → conecte ao **fluxo normal** (o node que vinha antes)

Para fazer isso:
1. Clique na bolinha de saída **FALSE** (segunda saída) do `Google Desconectado?`
2. Arraste até o node do fluxo normal de agenda

### 4.4 — Pode Enviar = FALSE
`Pode Enviar Nudge?` FALSE → conecte ao **mesmo fluxo normal**

### 4.5 — Depois de registrar nudge
`Registrar Nudge Enviado` → conecte ao **mesmo fluxo normal**

### Resultado visual:
```
                                    ┌─ FALSE ──→ fluxo normal
Checar Google → Google Desconectado?
                                    └─ TRUE ──→ Buscar Nudge → Pode Enviar?
                                                                ├─ FALSE → fluxo normal
                                                                └─ TRUE → Enviar Nudge → Registrar → fluxo normal
```

**Todos os caminhos terminam no fluxo normal.** O nudge é só um "desvio" que envia a mensagem e volta.

---

## PASSO 5 — Conectar o Grupo B (handler de botões)

### 5.1 — No Switch "Tipo de Ação" (que roteia botões)
Adicionar 2 novas branches:

1. Clique no Switch "Tipo de Ação"
2. Clique em **Add Output** (ou "Add Value")
3. Nova condição:
   - Left: `{{ $json.buttonId }}`
   - Operator: **equals**
   - Right: `gc_sim`
   - Output name: `Google Sim`

4. Clique em **Add Output** de novo:
   - Left: `{{ $json.buttonId }}`
   - Operator: **equals**
   - Right: `gc_nao`
   - Output name: `Google Não`

### 5.2 — Conectar saídas
- Branch **Google Sim** → `Registrar Sim` (já conecta ao `Enviar Tutorial Google`)
- Branch **Google Não** → `Registrar Não` (já conecta ao `Responder Não Google`)

### 5.3 — Problema: Registrar Não precisa do total_nao atual

O node `Registrar Não` usa `$('Buscar Nudge').item.json.total_nao` — mas quando vem do handler de botões, não passou pelo `Buscar Nudge`.

**Solução:** Adicionar um GET antes do `Registrar Não`:

1. Adicionar um node **Supabase Get** entre o Switch e o `Registrar Não`:
   - Tabela: `gc_nudge`
   - Filtro: `user_id = {{ $('setar_user').item.json.id_user }}`
   - Nome: `Buscar Nudge (Não)`

2. No `Registrar Não`, trocar a referência:
   - De: `$('Buscar Nudge').item.json.total_nao`
   - Para: `$('Buscar Nudge (Não)').item.json.total_nao`

3. Conectar: Switch → `Buscar Nudge (Não)` → `Registrar Não` → `Responder Não Google`

---

## PASSO 6 — Verificar credenciais

Clique em cada node e confirme que a credencial está selecionada:

| Node | Credencial |
|------|-----------|
| Checar Google Connect | Total Supabase |
| Buscar Nudge | Total Supabase |
| Enviar Nudge Google | WhatsApp Header Auth |
| Registrar Nudge Enviado | Total Supabase |
| Registrar Sim | Total Supabase |
| Enviar Tutorial Google | WhatsApp Header Auth |
| Registrar Não | Total Supabase |
| Responder Não Google | WhatsApp Header Auth |

Se algum node mostrar credencial em vermelho, clique e selecione a correta.

---

## PASSO 7 — Testar

1. Salve o workflow
2. Garanta que o usuário de teste tem `google_connect_status = false` no profiles
3. Mande uma mensagem de agenda: "o que tenho pra amanhã?"
4. Deve receber:
   - A resposta da agenda (normal)
   - MAIS a mensagem de nudge com botões "✅ Sim, conectar" e "❌ Agora não"
5. Clique em "✅ Sim, conectar" → deve receber tutorial com link
6. OU clique em "❌ Agora não" → deve receber "Sem problemas!"
7. Mande outra mensagem de agenda → NÃO deve receber nudge (cooldown 3 dias)

---

## Resumo dos arquivos

| Arquivo | O que é |
|---------|---------|
| `NODES-NUDGE-GOOGLE.json` | JSON dos 10 nodes — importar no n8n |
| `IMPLEMENTACAO-NUDGE-GOOGLE.md` | Documentação técnica completa |
| `TUTORIAL-INSTALACAO-NUDGE.md` | Este tutorial passo a passo |
