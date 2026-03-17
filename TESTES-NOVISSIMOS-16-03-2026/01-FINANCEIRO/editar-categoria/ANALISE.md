# Editar Categoria de Gasto — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL (LATÊNCIA)

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "muda categoria restaurante pra alimentação" | 45.0s | Funcionou | ⚠️ |
| P2 | "muda delivery pra categoria alimentação" | 11.5s | Funcionou | ✅ |
| P3 | "muda lanchonete pra alimentação" | 26.9s | Funcionou | ⚠️ |
| P4 | "coloca parking na categoria transporte" | 13.7s | Funcionou | ✅ |
| P5 | "joga rodízio pra categoria lazer" | 13.7s | Funcionou | ✅ |

## Bugs Encontrados

### Bug: Latência alta (27-45s em 2 casos)
- **Frequência:** 2/5 (40%)
- **Funcionalidade:** Funciona sempre, mas demora demais
- **Onde ocorre:** AI Agent → 2 tool calls (buscar_financeiro + editar_financeiro)
- **Causa raiz:** Cada tool call faz HTTP request pra sub-webhook, que passa por Redis nodes. Com Redis na Europa: ~300ms x 21 nodes x 2 calls = ~12s só de Redis. Mais o tempo da IA (GPT-4.1-mini) = 25-45s total.
- **Fix:** Redis local (elimina ~10-15s) ou consolidar busca+edição em 1 tool call

### Conclusão
Não é bug funcional — sempre acerta. É problema de performance. Redis local resolveria.
