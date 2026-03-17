# Buscar Gastos por Categoria — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "mostra gastos de alimentação" | 9.7s | Filtrou correto | ✅ |
| P2 | "busca gastos de transporte" | 7.1s | Filtrou correto | ✅ |
| P3 | "quanto gastei com moradia?" | 7.0s | Filtrou correto | ✅ |
| P4 | "gastos de saúde" | 9.3s | Filtrou correto | ✅ |
| P5 | "quanto torrei em outros?" | 51.5s | Filtrou correto | ⚠️ |

## Bugs Encontrados

### Bug: Latência extrema em P5 (51s)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** AI Agent → tool `buscar_financeiro`
- **Causa raiz:** Categoria "Outros" tem muitos registros (boletos, pix, investimentos). A query retorna dezenas de registros. Combinado com latência do Redis (servidor na Europa), resultou em 51s.
- **Impacto:** UX ruim para categorias com muitos registros
- **Fix:** Limitar retorno a 20 registros mais recentes, ou instalar Redis local

### Conclusão
Funciona bem na maioria dos casos. Latência problemática apenas com categorias muito populosas.
