# Investimento/Poupança — Análise Detalhada
**Score: 1/5** | Status: 🔴 CRÍTICO

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "coloca 300 na poupança" | 4.9s | REGISTROU R$300 | ❌ |
| P2 | "investe 200 em bitcoin" | 4.9s | REGISTROU R$200 | ❌ |
| P3 | "compra 3 bitcoins" | 4.9s | Recusou | ✅ |
| P4 | "guarda 1000 na reserva" | 4.9s | REGISTROU R$1000 | ❌ |
| P5 | "aplica 2000 em CDB" | 4.9s | REGISTROU R$2000 | ❌ |

## Bugs Encontrados

### Bug CRÍTICO: Investimentos viram gastos
- **Frequência:** 4/5 (80%)
- **Mesma causa raiz do Bug ação vs declaração**
- **Por que P3 acertou:** "compra 3 bitcoins" não tem valor monetário explícito (3 unidades, não reais)
- **Fix:** Adicionar ao classificador e prompt: investir, aplicar, guardar, depositar → NÃO registrar

### Conclusão: Mesmo padrão do ação vs declaração. Correção no classificador resolve ambos.
