# Excluir Evento Recorrente (uma ocorrência) — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "cancela academia de segunda" | 7.1s | "Não encontrei" | ❌ |
| P2 | "cancela corrida de terça" | 13.9s | Excluiu | ✅ |
| P3 | "tira musculação de quarta" | 15.9s | Excluiu | ✅ |
| P4 | "exclui pilates de terça" | 14.1s | Excluiu | ✅ |
| P5 | "tira futebol desse sábado" | 7.1s | "Não encontrei" | ❌ |

## Bugs Encontrados

### Bug: Não encontra instância de recorrente
- **Frequência:** 2/5 (40%)
- **Onde ocorre:** Webhook `busca-total-evento` → Supabase query
- **Causa raiz:** Eventos recorrentes são armazenados com `rrule` no registro base. Instâncias individuais podem não ter row separada no banco. A busca por `start_event` de uma data específica falha se a instância não foi expandida.
- **Padrão:** P1 (academia) e P5 (futebol) foram os recém-criados. Pode ser que a expansão de instâncias leva tempo.
- **Fix:** No webhook de busca, além de `start_event`, considerar eventos com `is_recurring = true` cujo `rrule` inclui o dia pedido. Ou garantir expansão imediata ao criar.

### Conclusão: Bug estrutural na busca de recorrentes. Precisa mudar lógica de busca.
