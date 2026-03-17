# Excluir Gasto Específico — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "apaga gasto do restaurante" | 32.2s | Excluiu | ✅ |
| P2 | "tira o delivery" | 11.6s | Excluiu | ✅ |
| P3 | "exclui lanchonete" | 26.9s | Excluiu | ⚠️ |
| P4 | "deleta parking" | 7.1s | "Não encontrei EVENTO" | ❌ |
| P5 | "some com o rodízio" | 13.7s | Excluiu | ✅ |

## Bugs Encontrados

### Bug: Classificador confundiu gasto com evento (P4)
- **Frequência:** 1/5 (20%)
- **O que aconteceu:** "deleta parking" foi enviado para `excluir_evento_agenda` ao invés de `excluir` (financeiro). Respondeu "Não encontrei EVENTO parking".
- **Onde ocorre:** Classificador `Escolher Branch`
- **Causa raiz:** "parking" é nome ambíguo. O classificador não sabe se é gasto ou evento sem contexto. Mesmo bug do editar-nome (#7).
- **Fix:** Mesma correção — priorizar gasto como default quando ambíguo

### Conclusão
Funciona na maioria dos casos. Falha com nomes ambíguos que podem ser gasto ou evento.
