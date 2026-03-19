# Metodologia de Auditoria — Exclusão de Compromissos

**Funcionalidade:** `agenda/04-exclusao-compromissos`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp → Fix Conflito v2
  → Escolher Branch → excluir_evento_agenda
    → prompt_excluir (prompt de exclusão)
    → AI Agent → Tool: excluir_evento (httpRequestTool)
      → Calendar WebHooks (webhook "Excluir eventos - Webhook")
        → Busca evento por nome/critérios
        → Se Google: excluir_evento_google (DELETE Google Calendar API)
        → delete_supabase / delete_supabase1 (DELETE calendar)
        → Retorna confirmação
    → IA responde "🗑️ Evento excluído!"
```

### ⚠️ COMPORTAMENTO ASYNC — igual a edição

### ⚠️ Exclusão de recorrentes — PROBLEMÁTICA

A-200 mostrou falhas consistentes na exclusão de eventos recorrentes:
- IA diz "excluído" mas evento permanece
- Pedido de excluir "a corrida de terça" não identifica a ocorrência

### Nós relevantes

| Nó | Workflow | Função |
|----|----------|--------|
| `excluir_evento` | Fix Conflito v2 | Tool HTTP |
| `Excluir eventos - Webhook` | Calendar WebHooks | Recebe exclusão |
| `excluir_evento_google` | Calendar WebHooks | DELETE Google Calendar API |
| `delete_supabase` / `delete_supabase1` | Calendar WebHooks | DELETE calendar |

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Buscar evento alvo → EVENTO_ANTES (salvar id)
  1.2  Contar calendar → COUNT_ANTES

PASSO 2 — ENVIAR MENSAGEM

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — ESPERAR ASYNC (20s)

PASSO 5 — VERIFICAR
  5.1  COUNT_DEPOIS = COUNT_ANTES - 1?
  5.2  Buscar por id do evento → deve retornar vazio
  5.3  Nenhum outro evento afetado (COUNT diminuiu em EXATAMENTE 1)
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | IA confirmou | "🗑️ Evento excluído!" | Não encontrou |
| 2 | COUNT -1 | COUNT_DEPOIS = COUNT_ANTES - 1 | Não mudou |
| 3 | Evento sumiu | Busca por id retorna vazio | Ainda existe |
| 4 | Nada mais afetado | Só o evento alvo foi removido | Removeu mais |
| 5 | Google sync | Evento removido do Google Calendar | Permanece no Google |

---

## 4. Protocolo de diagnóstico de erros

```
CAMADA 1 — CLASSIFICADOR: Foi pra excluir_evento_agenda?
CAMADA 2 — AI AGENT: Chamou excluir_evento? Com ID correto?
CAMADA 3 — BUSCA: Encontrou o evento certo?
CAMADA 4 — DELETE: Supabase DELETE executou?
CAMADA 5 — GOOGLE: Google Calendar DELETE executou?
CAMADA 6 — ASYNC: Verificou cedo demais?

CAUSA COMUM: Exclusão de recorrentes — sistema não sabe qual ocorrência excluir.
```

---

## 5. Testes

**🟢 Quick (3 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| DEL-Q1 | "cancela a reunião" | calendar: -1, evento sumiu |
| DEL-Q2 | "exclui o dentista" | calendar: -1 |
| DEL-Q3 | Excluir evento que não existe | IA diz "não encontrei" |

**🟡 Broad (Quick + 5 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| DEL-B1 | "apaga tudo de amanhã" | Exclusão múltipla: COUNT - N |
| DEL-B2 | "cancela a academia de segunda" | Excluir UMA ocorrência de recorrente ⚠️ |
| DEL-B3 | "tira todos os eventos de sexta" | Exclusão por dia |
| DEL-B4 | Confirmar com "sim" ou "1" | Se IA perguntou qual excluir |
| DEL-B5 | Google sync após exclusão | Evento sumiu do Google? |

**🔴 Complete (Broad + 4 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| DEL-C1 | Excluir recorrente inteiro | Registro com is_recurring=true removido |
| DEL-C2 | Excluir 1 ocorrência de recorrente | exdates preenchido? |
| DEL-C3 | Excluir último evento do dia | Dia fica vazio na agenda |
| DEL-C4 | Excluir e re-verificar Google | Sem fantasma no Google Calendar |

---

## 6. Formato do log

```markdown
| ID | Input | IA disse | COUNT antes | COUNT depois | Delta | Evento sumiu? | Veredicto |
```

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Suporte a exclusão de ocorrência única (exdates) | Recorrentes sem perder todas |
| Confirmação antes de excluir múltiplos | Evitar exclusão acidental |
| Logar exclusão no log_total com id do evento | Rastreio |
