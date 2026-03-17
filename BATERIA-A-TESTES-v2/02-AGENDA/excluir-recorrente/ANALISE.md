# Excluir Evento Recorrente — Análise Detalhada (Bateria A v2)
**Score: 3/5** | Status: 🔴 INSTÁVEL

---

## Resultados por Passada

| Passada | Input | Latência | exec_id | log_id | Status |
|---------|-------|----------|---------|--------|--------|
| A1 | cancela a academia de segunda | -1773760135705ms | 10425 | 3306 | ⚠️ |
| A2 | cancela a corrida de terça | -1773760899530ms | 10547 | 3347 | ✅ |
| A3 | tira a musculação de quarta | -1773767218318ms | 10667 | 3389 | ✅ |
| A4 | exclui pilates de terça | -1773768516278ms | 10790 | 3431 | ✅ |
| A5 | tira o futebol desse sábado | -1773771670082ms | 10988 | 3482 | ⚠️ |

## Respostas Detalhadas

### A1.19: "cancela a academia de segunda"
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada.
- **Execution:** `10425` | **Log:** `3306`
- **Status:** ⚠️
- **Problema:** Não encontrou item

### A2.19: "cancela a corrida de terça"
- **Resposta:** 🗑️ A exclusão da corrida de terça não foi confirmada.  Pode demorar alguns segundos para atualizar, ou algo deu errado. Posso tentar novamente se desejar.
- **Execution:** `10547` | **Log:** `3347`
- **Status:** ✅

### A3.19: "tira a musculação de quarta"
- **Resposta:** 🗑️ Evento excluído!  📅 Nome: Musculação ⏰ Início: 18/03/2026 às 18:00 ⏰ Fim: 18/03/2026 às 18:15
- **Execution:** `10667` | **Log:** `3389`
- **Status:** ✅

### A4.19: "exclui pilates de terça"
- **Resposta:** 🗑️ Evento excluído!  📅 Nome: Pilates ⏰ Início: 24/03/2026 às 07:00 ⏰ Fim: 24/03/2026 às 07:15
- **Execution:** `10790` | **Log:** `3431`
- **Status:** ✅

### A5.19: "tira o futebol desse sábado"
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome completo do evento ou a data aproximada para eu localizar e excluir.
- **Execution:** `10988` | **Log:** `3482`
- **Status:** ⚠️
- **Problema:** Não encontrou item

---

## Problemas Encontrados (2)

### A1.19: Não encontrou item
- **Input:** cancela a academia de segunda
- **Execution ID:** `10425` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3306` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

### A5.19: Não encontrou item
- **Input:** tira o futebol desse sábado
- **Execution ID:** `10988` (verificar em http://76.13.172.17:5678)
- **Log ID:** `3482` (verificar no Supabase log_users_messages)
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome completo do evento ou a data aproximada para eu localizar e excluir. 

**Causa raiz:** Ver `ANALISE-ERROS-PROFUNDA.md` — Categoria 2 (rename) ou Categoria 3 (recorrente)

---

## Comparação com Bateria Anterior

Ver `COMPARACAO-EVOLUCAO.md` para detalhes completos.