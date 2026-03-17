# Cancelar Lembrete Recorrente — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "cancela lembrete do aluguel" | 18.2s | Excluiu | ✅ |
| P2 | "remove lembrete do relatório" | 14.0s | Excluiu | ✅ |
| P3 | "tira lembrete da internet" | 7.1s | "Não encontrei" | ❌ |
| P4 | "tira o do condomínio" | 7.1s | "Não encontrei" | ❌ |
| P5 | "cancela do plano de saúde" | 9.3s | Excluiu | ✅ |

## Bugs Encontrados

### Bug: Busca por nome parcial falha
- **Frequência:** 2/5 (40%)
- **P3:** "internet" não encontrou "Pagar Internet"
- **P4:** "condomínio" não encontrou "Pagar Condomínio". Além disso, "tira o do condomínio" é muito vago.
- **Causa raiz:** Busca pode não estar usando ILIKE, ou a IA não monta o nome completo.
- **Fix:** Webhook busca usar ILIKE + IA buscar variações

### Conclusão: Falha com nomes parciais/vagos. Funciona com nomes mais completos.
