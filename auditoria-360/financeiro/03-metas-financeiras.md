# Metodologia de Auditoria — Metas Financeiras

**Funcionalidade:** `financeiro/03-metas-financeiras`
**Versão:** 1.0.0
**Status da funcionalidade:** ❌ NÃO IMPLEMENTADA no WhatsApp

---

## 1. Mapa do sistema

### Diagnóstico

Esta funcionalidade **NÃO existe** no bot WhatsApp:

- **Nenhuma tabela** de metas no Supabase (não existe `financial_goals`, `savings_goals`, `metas`)
- **Nenhum branch** no classificador (`Escolher Branch`) para metas
- **Prompt do `registrar_gasto`** diz explicitamente: "NÃO cria planejamentos financeiros, orçamentos ou metas"

### Escopo de auditoria

Como a funcionalidade não existe, o escopo é **verificar que o sistema RECUSA corretamente** pedidos de meta, sem criar registros indevidos em nenhuma tabela.

---

## 2. Endpoints de verificação

Mesmos de `01-despesas-receitas` para `spent`, `log_users_messages` e N8N API.
Adicionalmente, verificar que NENHUMA tabela nova foi criada.

---

## 3. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Contar spent do user → SPENT_ANTES
  1.2  Contar calendar do user → CAL_ANTES
  1.3  Último log_id → LAST_LOG_ID

PASSO 2 — ENVIAR MENSAGEM (pedido de meta)

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — VERIFICAR RECUSA
  4.1  ai_message NÃO contém "✅" ou "registrado" ou "criado" ou "meta definida"
  4.2  ai_message contém recusa ou redirecionamento
  4.3  spent count = SPENT_ANTES (nada criado)
  4.4  calendar count = CAL_ANTES (nada criado)

PASSO 5 — REGISTRAR
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | IA recusa | Responde que não pode criar meta | Diz que criou |
| 2 | Nada criado | Counts iguais em todas as tabelas | Algo aumentou |
| 3 | Não confunde com gasto | "economizar 500" NÃO vira gasto de R$500 | Registrou como gasto |

---

## 5. Protocolo de diagnóstico de erros

Mesmo protocolo de `02-limites-categoria.md` (seção 5).

Causas raiz mais prováveis:
- **CLASSIFICAÇÃO_ERRADA:** "meta de 500" → classificado como `criar_gasto` (valor 500)
- **RESPOSTA_ERRADA:** IA diz que criou meta mas nada aconteceu
- **COMPORTAMENTO_NAO_DOCUMENTADO:** IA sugere usar o app (pode ser correto)

---

## 6. Testes

**🟢 Quick (2 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| META-Q1 | "quero criar uma meta de economizar 500 por mês" | Recusa. Nada criado. |
| META-Q2 | "define uma meta de guardar 1000 até dezembro" | Recusa. Nada criado. |

**🟡 Broad (Quick + 3 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| META-B1 | "quanto falta pra minha meta?" | Recusa (não existe meta). |
| META-B2 | "cria um objetivo financeiro de 5000" | Recusa. NÃO criar gasto. |
| META-B3 | "quero juntar dinheiro pra viagem" | Recusa. Branch = padrao. |

**🔴 Complete (Broad + 3 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| META-C1 | "meta: alimentação máximo 500" | NÃO confundir com limite de categoria. Recusar. |
| META-C2 | "economizar 200 por mês" | NÃO registrar como gasto/receita. |
| META-C3 | "progresso da minha meta" | Recusar (não existe). |

---

## 7. Formato do log

```markdown
## Execução: {DATA} — Nível: {QUICK|BROAD|COMPLETE}

| ID | Input | IA recusou? | Algo criado? | Veredicto |
|----|-------|-------------|-------------|-----------|
```

---

## 8. Melhorias sugeridas

| O que | Decisão necessária |
|-------|-------------------|
| Implementar metas financeiras (tabela + branch + workflow) | PO decide roadmap |
| Se implementar: branch `criar_meta` no classificador | @dev |
| Se implementar: tabela `financial_goals` (user_id, name, target_amount, current_amount, deadline) | @dev |
