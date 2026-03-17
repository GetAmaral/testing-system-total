# Renomear Evento — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "renomeia dentista pra consulta odonto" | 16.0s | Renomeou | ✅ |
| P2 | "troca reunião pra alinhamento semanal" | 11.4s | Renomeou | ✅ |
| P3 | "muda banco pra resolver pendências" | 7.1s | PERGUNTOU | ⚠️ |
| P4 | "troca consulta médica pra check-up" | 11.7s | Renomeou | ✅ |
| P5 | "muda oculista pra oftalmologista" | 11.5s | Renomeou | ✅ |

## Bugs Encontrados

### Bug: Perguntou ao invés de fazer (P3)
- **Frequência:** 1/5 (20%)
- **O que aconteceu:** "muda banco pra resolver pendências" → "Quer que eu atualize a descrição?"
- **Causa raiz:** System prompt diz "NUNCA peça confirmação para CRIAR" mas não inclui EDITAR. "Resolver pendências" é ambíguo — pode ser nome novo ou descrição.
- **Fix:** Expandir regra: "NUNCA peça confirmação para CRIAR ou EDITAR"

### Conclusão: Funciona 80%. Bug menor de UX — pergunta ao invés de agir.
