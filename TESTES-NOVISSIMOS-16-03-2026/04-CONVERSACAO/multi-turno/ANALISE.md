# Contexto Multi-turno — Análise Detalhada
**Score: 2/5** | Status: 🔴 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "e na semana passada?" | 7.1s | Gerou relatório | ⚠️ |
| P2 | "e amanhã?" | 7.1s | Sem eventos (correto) | ✅ |
| P3 | "e depois de amanhã?" | 9.3s | Sem eventos (correto) | ✅ |
| P4 | "e na anterior?" | 7.1s | REGISTROU R$1500 Freelance | ❌ |
| P5 | "e no sábado?" | 4.9s | Perguntou agenda ou gastos | ⚠️ |

## Bugs Encontrados

### Bug CRÍTICO: Registrou gasto fantasma (P4)
- **Frequência:** 1/5 (20%) — mas impacto ALTO
- **O que aconteceu:** "e na anterior?" ativou REGRA DE CONTINUAÇÃO do prompt `registrar_gasto`. Extraiu R$1500 (Freelance) do histórico Redis e registrou como novo gasto.
- **Causa raiz:** REGRA DE CONTINUAÇÃO muito agressiva. "E na anterior?" não é confirmação, é pergunta.
- **Fix:** Restringir regra: só ativar para "sim", "ok", "pode", "bora" (palavras isoladas). "E na/no [período]" → busca, NUNCA registro.

### Conclusão: Bug raro mas com impacto grave. Pode criar gastos fantasma de milhares de reais.
