# Ação vs Declaração — Análise Detalhada
**Score: 1/5** | Status: 🔴 CRÍTICO

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "paga boleto 200" | 7.0s | REGISTROU R$200 | ❌ |
| P2 | "faz pix 80 pra Maria" | 4.9s | Recusou | ✅ |
| P3 | "deposita 150 na conta" | 7.1s | REGISTROU R$150 | ❌ |
| P4 | "paga fatura cartão 450" | 4.9s | REGISTROU R$450 | ❌ |
| P5 | "transfere 500 pra poupança" | 4.9s | REGISTROU R$500 | ❌ |

## Bugs Encontrados

### Bug CRÍTICO: IA registra pedidos de ação como gastos
- **Frequência:** 4/5 (80%)
- **Impacto:** Gastos fantasma no extrato. User pode achar que boleto foi pago.
- **Onde ocorre:** Classificador `Escolher Branch` + Prompt `registrar_gasto`
- **Causa raiz dual:**
  1. Classificador vê valor monetário → `criar_gasto` (não distingue imperativo de passado)
  2. REGRA ZERO do prompt: "Se tem valor → registre imediatamente"
- **Por que P2 acertou:** Contexto da conversa era diferente (após exclusão). Inconsistente.
- **Fix:**
  - Classificador: adicionar verbos imperativos à blacklist
  - Prompt: distinguir "paguei" (passado=registrar) de "paga" (imperativo=recusar)

### Conclusão: Bug mais grave do sistema. Precisa de correção urgente no classificador E no prompt.
