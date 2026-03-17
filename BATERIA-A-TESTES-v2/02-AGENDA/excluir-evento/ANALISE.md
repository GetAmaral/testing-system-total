# Excluir Evento Específico — Análise Detalhada (Bateria A v2)
**Score: 1/5** | Status: 🔴 INSTÁVEL

---

## Resultados por Passada

| Passada | Input | Latência | exec_id | log_id | Status |
|---------|-------|----------|---------|--------|--------|
| A1 | exclui a consulta odonto | -1773760105467ms | 10422 | 3305 | ✅ |
| A2 | tira o alinhamento semanal | -1773760885628ms | 10544 | 3346 | ⚠️ |
| A3 | cancela resolver pendências | -1773767204340ms | 10667 | 3388 | ⚠️ |
| A4 | remove check-up | -1773768469536ms | 10787 | 3430 | ⚠️ |
| A5 | apaga oftalmologista | -1773771658768ms | 10985 | 3481 | ⚠️ |

## Respostas Detalhadas

### A1.18: "exclui a consulta odonto"
- **Resposta:** 🗑️ Encontrei 2 eventos com o nome "Consulta Odonto": 1. 📅 20/03/2026 às 00:00 2. 📅 20/03/2026 às 15:00  Por favor, me diga qual deles você quer excluir: responde com o número (1 ou 2).
- **Execution:** `10422` | **Log:** `3305`
- **Status:** ✅

### A2.18: "tira o alinhamento semanal"
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada.
- **Execution:** `10544` | **Log:** `3346`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A3.18: "cancela resolver pendências"
- **Resposta:** Não encontrei nenhum evento chamado "Resolver Pendências" na sua agenda para os próximos dias. Posso ajudar com mais alguma coisa?
- **Execution:** `10667` | **Log:** `3388`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A4.18: "remove check-up"
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição.
- **Execution:** `10787` | **Log:** `3430`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A5.18: "apaga oftalmologista"
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada.
- **Execution:** `10985` | **Log:** `3481`
- **Status:** ⚠️
- **Problema:** Não encontrou item

---

## Problemas Encontrados (4)

### A2.18: Não encontrou item
- **Input:** tira o alinhamento semanal
- **Execution ID:** `10544` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3346` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

### A3.18: Não encontrou item
- **Input:** cancela resolver pendências
- **Execution ID:** `10667` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3388` (verificar no Supabase log_users_messages)
- **Resposta:** Não encontrei nenhum evento chamado "Resolver Pendências" na sua agenda para os próximos dias. Posso ajudar com mais alguma coisa? 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

### A4.18: Não encontrou item
- **Input:** remove check-up
- **Execution ID:** `10787` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3430` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

### A5.18: Não encontrou item
- **Input:** apaga oftalmologista
- **Execution ID:** `10985` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3481` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

---

## Comparação com Bateria Anterior

Ver `COMPARACAO-EVOLUCAO.md` para detalhes completos.