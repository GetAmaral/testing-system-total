# Excluir Múltiplos Gastos — Análise Detalhada (Bateria A v2)
**Score: 1/5** | Status: 🔴 INSTÁVEL

---

## Resultados por Passada

| Passada | Input | Latência | exec_id | log_id | Status |
|---------|-------|----------|---------|--------|--------|
| A1 | apaga todos os gastos de uber | -1773759921570ms | 10398 | 3297 | ⚠️ |
| A2 | remove todos os gastos de gasolina | -1773760740901ms | 10520 | 3338 | ⚠️ |
| A3 | deleta tudo de mercado | -1773767081850ms | 10644 | 3380 | ⚠️ |
| A4 | apaga tudo que tem de luz | -1773768321561ms | 10763 | 3422 | ⚠️ |
| A5 | limpa todos os tesouro direto | -1773769085486ms | 10908 | 3462 | ✅ |

## Respostas Detalhadas

### A1.10: "apaga todos os gastos de uber"
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição.
- **Execution:** `10398` | **Log:** `3297`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A2.10: "remove todos os gastos de gasolina"
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição.
- **Execution:** `10520` | **Log:** `3338`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A3.10: "deleta tudo de mercado"
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição.
- **Execution:** `10644` | **Log:** `3380`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A4.10: "apaga tudo que tem de luz"
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição.
- **Execution:** `10763` | **Log:** `3422`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A5.10: "limpa todos os tesouro direto"
- **Resposta:** Isso está fora do que eu consigo fazer, mas posso te ajudar a registrar seus gastos ou organizar sua agenda!
- **Execution:** `10908` | **Log:** `3462`
- **Status:** ✅

---

## Problemas Encontrados (4)

### A1.10: Não encontrou item
- **Input:** apaga todos os gastos de uber
- **Execution ID:** `10398` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3297` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 1/4 (item pode não existir)

### A2.10: Não encontrou item
- **Input:** remove todos os gastos de gasolina
- **Execution ID:** `10520` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3338` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 1/4 (item pode não existir)

### A3.10: Não encontrou item
- **Input:** deleta tudo de mercado
- **Execution ID:** `10644` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3380` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 1/4 (item pode não existir)

### A4.10: Não encontrou item
- **Input:** apaga tudo que tem de luz
- **Execution ID:** `10763` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3422` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 1/4 (item pode não existir)

---

## Comparação com Bateria Anterior

Ver `COMPARACAO-EVOLUCAO.md` para detalhes completos.