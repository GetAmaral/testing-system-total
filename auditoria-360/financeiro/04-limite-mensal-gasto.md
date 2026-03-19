# Metodologia de Auditoria — Limite Mensal de Gasto

**Funcionalidade:** `financeiro/04-limite-mensal-gasto`
**Versão:** 1.0.0
**Status da funcionalidade:** ❌ NÃO IMPLEMENTADA no WhatsApp (limite GLOBAL mensal não existe; existe apenas limite POR CATEGORIA via frontend — ver `02-limites-categoria`)

---

## 1. Mapa do sistema

### Diagnóstico

| Componente | Existe? | Detalhe |
|-----------|---------|---------|
| Tabela `monthly_budget` ou similar | ❌ | Não existe |
| `category_limits` (por categoria) | ✅ | Mas é POR CATEGORIA, não global |
| Branch no classificador | ❌ | Não há `definir_limite` |
| Prompt do agent | ❌ | Diz: "NÃO define limites de gasto por categoria" |
| Workflow N8N | ❌ | Nenhum workflow define limites via WhatsApp |

### Diferença com `02-limites-categoria`

- **02:** Limite POR categoria. Tabela `category_limits`. Definido via frontend. AI Agent recebe via `infos.colocar_limite`.
- **04:** Limite GLOBAL mensal. **Não existe** em nenhuma camada.

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Contar category_limits do user → LIMITS_ANTES
  1.2  Contar spent do user → SPENT_ANTES
  1.3  Último log_id → LAST_LOG_ID

PASSO 2 — ENVIAR MENSAGEM

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — VERIFICAR
  4.1  ai_message indica recusa
  4.2  category_limits count = LIMITS_ANTES (nenhum limite criado)
  4.3  spent count = SPENT_ANTES (nenhum gasto criado)

PASSO 5 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | IA recusa definir limite global | Responde que não pode | Diz que definiu |
| 2 | Nenhum limite criado | category_limits inalterado | Criou limite |
| 3 | Não confunde com gasto | spent inalterado | Registrou "1500" como gasto |
| 4 | Não confunde com busca | "meu limite de gastos" → recusa, não retorna extrato | Retorna gastos |

---

## 4. Protocolo de diagnóstico de erros

Mesmo protocolo de `02-limites-categoria.md` (seção 5).

Causas raiz mais prováveis:
- **CLASSIFICAÇÃO_ERRADA:** "limita meus gastos em 1500" → `criar_gasto` (valor 1500)
- **RESPOSTA_ERRADA:** IA diz que definiu limite mas nada mudou
- **COMPORTAMENTO_NAO_DOCUMENTADO:** IA sugere usar o app

---

## 5. Testes

**🟢 Quick (2 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| LIMM-Q1 | "define um limite de 3000 por mês" | Recusa. Nada criado. |
| LIMM-Q2 | "quero gastar no máximo 2000 esse mês" | Recusa. Nada criado. |

**🟡 Broad (Quick + 4 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| LIMM-B1 | "quanto é meu limite de gastos?" | Recusa. NÃO retorna extrato. |
| LIMM-B2 | "coloca um teto de 5000 no mês" | Recusa. |
| LIMM-B3 | "limita meus gastos em 1500" | NÃO criar gasto de R$1500. Recusar. |
| LIMM-B4 | "meu orçamento mensal é 4000" | NÃO registrar como receita. Recusar. |

**🔴 Complete (Broad + 3 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| LIMM-C1 | "quanto falta pro meu limite?" | Recusar (não existe). |
| LIMM-C2 | "estourei meu limite esse mês?" | Recusar. NÃO inventar limite. |
| LIMM-C3 | "remove meu limite mensal" | Recusar (nada pra remover). |

---

## 6. Formato do log

```markdown
## Execução: {DATA} — Nível: {QUICK|BROAD|COMPLETE}

| ID | Input | IA recusou? | category_limits mudou? | spent mudou? | Veredicto |
|----|-------|-------------|----------------------|--------------|-----------|
```

---

## 7. Melhorias sugeridas

| O que | Decisão necessária |
|-------|-------------------|
| Criar tabela `monthly_budget` (user_id, amount, month) | PO decide |
| Branch `definir_limite` no classificador | PO decide |
| Diferenciar limite global vs por categoria | PO decide |
