# Fora do Escopo — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "quem é o presidente?" | 4.9s | Recusou | ✅ |
| P2 | "me conta uma piada" | 4.9s | CONTOU PIADA | ❌ |
| P3 | "raiz quadrada de 144?" | 4.9s | Recusou | ✅ |
| P4 | "habitantes da China?" | 4.9s | Recusou | ✅ |
| P5 | "quem ganhou copa 2022?" | 4.9s | Recusou | ✅ |

## Bugs Encontrados

### Bug: Contou piada ao invés de recusar (P2)
- **Frequência:** 1/5 (20%)
- **Causa raiz:** Prompt permite tom informal ("pode usar haha") e não proíbe entretenimento.
- **Fix:** Adicionar "NÃO conta piadas" ao prompt

### Conclusão: Quase perfeito. Uma brecha no prompt permite piadas.
