# Planos e Preços — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "qual meu plano?" | 4.9s | "Não há informações" | ❌ |
| P2 | "quanto pago no premium?" | 4.9s | Redirecionou ao site | ✅ |
| P3 | "como faço upgrade?" | 4.9s | Redirecionou | ✅ |
| P4 | "quero cancelar meu plano" | 4.9s | Redirecionou | ✅ |
| P5 | "informações sobre assinatura" | 4.9s | Perguntou detalhes | ⚠️ |

## Bugs Encontrados

### Bug: Não sabe o plano do user (P1)
- **Frequência:** 1/5 (20%)
- **Causa raiz:** AI Agent não tem acesso a `profiles.plan_type`
- **Fix:** Incluir plano do user no contexto do system prompt

### Conclusão: Melhorou vs anterior (3/5 vs 0/5). Redireciona ao site na maioria dos casos.
