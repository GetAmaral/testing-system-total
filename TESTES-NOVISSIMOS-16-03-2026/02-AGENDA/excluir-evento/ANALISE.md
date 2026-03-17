# Excluir Evento Específico — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "exclui consulta odonto" | 18.1s | Excluiu | ✅ |
| P2 | "tira alinhamento semanal" | 18.1s | Excluiu | ✅ |
| P3 | "cancela resolver pendências" | 4.9s | Pediu confirmação | ⚠️ |
| P4 | "remove check-up" | 7.1s | "Não encontrei" | ❌ |
| P5 | "apaga oftalmologista" | 15.9s | Excluiu | ✅ |

## Bugs Encontrados

### Bug 1: "Não encontrei" após rename (P4)
- **Frequência:** 1/5 (20%)
- **O que aconteceu:** Evento foi renomeado para "Check-Up" em P4.17, mas busca por "check-up" não encontrou.
- **Causa raiz:** Possível case sensitivity (Check-Up vs check-up) ou Google Calendar sync mismatch.
- **Fix:** Busca deve ser case-insensitive (ILIKE)

### Bug 2: Pediu confirmação ao invés de excluir (P3)
- **Frequência:** 1/5 (20%)
- **O que aconteceu:** "cancela resolver pendências" — a IA ficou em dúvida
- **Causa raiz:** Nome ambíguo ("resolver pendências" pode ser ação ou nome de evento)

### Conclusão: Funciona com nomes claros. Falha com nomes ambíguos ou case sensitivity.
