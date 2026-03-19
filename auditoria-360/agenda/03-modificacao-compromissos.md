# Metodologia de Auditoria — Modificação de Compromissos

**Funcionalidade:** `agenda/03-modificacao-compromissos`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp → Fix Conflito v2
  → Escolher Branch → editar_evento_agenda
    → prompt_editar1 (prompt de edição)
    → AI Agent → Tool: editar_eventos (httpRequestTool)
      → Calendar WebHooks (webhook "Editar eventos - webhook")
        → Busca evento por nome/critérios
        → Se Google conectado: editar_evento_google3 (Google Calendar API)
        → UPDATE calendar (Supabase)
        → Retorna confirmação
    → IA responde "Prontinho, atualizei seu evento."
```

### ⚠️ COMPORTAMENTO ASYNC

Edições de evento seguem o padrão assíncrono:
1. IA anuncia "Prontinho, atualizei" ANTES do banco atualizar
2. Tool HTTP é chamada para Calendar WebHooks
3. Calendar WebHooks executa UPDATE no Supabase + Google
4. Delay de 5-20s entre anúncio e atualização real

**OBRIGATÓRIO:** Esperar 20s após resposta da IA antes de verificar o banco.

### Bugs conhecidos

| Bug | Evidência | Status |
|-----|-----------|--------|
| **end_event não atualiza ao mover start_event** | T6 dos testes Watson: start mudou 25→27, end ficou em 25 | Confirmado |
| **Rename pode deletar evento do Google Calendar** | Bateria 04: rename retornou sucesso mas evento sumiu | Confirmado (Bateria 04) |

### Nós relevantes

| Nó | Workflow | Função |
|----|----------|--------|
| `editar_eventos` | Fix Conflito v2 | Tool HTTP → Calendar WebHooks |
| `Editar eventos - webhook` | Calendar WebHooks | Recebe edição |
| `editar_evento_google3` | Calendar WebHooks | PATCH Google Calendar API |
| `Update a row1` | Calendar WebHooks | UPDATE calendar (Supabase) |

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Buscar evento alvo por nome → EVENTO_ANTES (todos os campos)
  1.2  Contar calendar → COUNT_ANTES
  1.3  Último log_id → LAST_LOG_ID

PASSO 2 — ENVIAR MENSAGEM de edição

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — ESPERAR ASYNC (20s obrigatório)

PASSO 5 — VERIFICAR BANCO
  5.1  Buscar evento → EVENTO_DEPOIS
  5.2  Campo editado MUDOU?
  5.3  Campos NÃO editados permanecem iguais?
  5.4  end_event acompanhou start_event? ⚠️ bug conhecido
  5.5  COUNT_DEPOIS = COUNT_ANTES (sem duplicata, sem deleção)
  5.6  Se Google: session_event_id_google ainda presente?

PASSO 6 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | IA confirmou | "Prontinho, atualizei" | Erro ou não encontrou |
| 2 | Campo editado mudou | DEPOIS.{campo} ≠ ANTES.{campo} | Não mudou |
| 3 | Sem regressão | Outros campos iguais | Algo mudou que não devia |
| 4 | end_event coerente | end = start + duração original | end ficou com data antiga ⚠️ |
| 5 | Sem duplicata | COUNT igual | Criou novo em vez de editar |
| 6 | Evento não deletado | Evento ainda existe | Sumiu (bug rename) ⚠️ |
| 7 | Google sync | ID Google mantido ou atualizado | ID sumiu |

---

## 4. Protocolo de diagnóstico de erros

```
CAMADA 1 — CLASSIFICADOR: Foi pra editar_evento_agenda?
CAMADA 2 — AI AGENT: Chamou editar_eventos com parâmetros corretos?
CAMADA 3 — CALENDAR WH: Webhook de edição executou? Status=success?
CAMADA 4 — BUSCA: Encontrou o evento certo pra editar?
CAMADA 5 — UPDATE: Supabase UPDATE executou?
CAMADA 6 — GOOGLE: Edição refletiu no Google Calendar?
CAMADA 7 — ASYNC: Verificou cedo demais? Re-verificar após mais tempo.
```

**Causa raiz mais comum:** `ASYNC_INCOMPLETO` — verificação antes do UPDATE completar.

---

## 5. Testes

**🟢 Quick (3 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| MOD-Q1 | "muda a reunião pra 15h" | start_event mudou. end_event acompanhou? |
| MOD-Q2 | "passa a reunião pro dia 25" | start_event mudou data. end_event? ⚠️ |
| MOD-Q3 | "renomeia reunião pra alinhamento" | event_name mudou. Evento NÃO sumiu? ⚠️ |

**🟡 Broad (Quick + 5 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| MOD-B1 | "atrasa 30 minutos" | Edição relativa (+30min) |
| MOD-B2 | "antecipa pra 8h" | Edição pra mais cedo |
| MOD-B3 | Editar evento que não existe | IA diz que não encontrou |
| MOD-B4 | Editar com nome ambíguo (2 eventos similares) | IA pede clarificação |
| MOD-B5 | Verificar Google após edição | session_event_id_google intacto |

**🔴 Complete (Broad + 5 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| MOD-C1 | Editar recorrente (só uma ocorrência) | exdates preenchido? |
| MOD-C2 | Editar recorrente (todas) | rrule atualizado? |
| MOD-C3 | Múltiplas edições seguidas no mesmo evento | Estado final correto |
| MOD-C4 | Editar pra data no passado | Aceita ou recusa? |
| MOD-C5 | Verificar todos os campos pós-edição | Nenhuma regressão |

---

## 6. Formato do log

```markdown
| ID | Input | IA disse | Campo editado | Antes | Depois | end_event ok? | Google ok? | Veredicto |
```

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| **Corrigir end_event ao mover start_event** | Bug confirmado — end fica com data antiga |
| **Corrigir rename que deleta do Google** | Bug confirmado na Bateria 04 |
| Logar edição no log_total com campos old/new | Verificar sem depender de timing |
