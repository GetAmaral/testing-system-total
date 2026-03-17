# Criar Lembrete sem Horário — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "me lembra comprar pão" | 67.1s | TIMEOUT | ❌ |
| P2 | "lembrete buscar encomenda" | 5.0s | Criou 17h | ✅ |
| P3 | "lembrete levar cachorro pet" | 7.1s | Criou 17h | ✅ |
| P4 | "me lembra renovar CNH" | 4.9s | Criou 17h01 | ✅ |
| P5 | "lembrete pegar roupa lavanderia" | 7.1s | Criou 17h08 | ✅ |

## Bugs Encontrados

### Bug: TIMEOUT 67s (P1)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** AI Agent (maxTries=5, waitBetweenTries=300ms)
- **Causa raiz:** OpenAI retornou erro/timeout. 5 retries x ~13s = ~65s. Sem horário, a IA precisa decidir um horário, o que adiciona complexidade.
- **Fix:** Reduzir maxTries de 5 para 2

### Observação UX:
A IA sempre atribui ~17h quando não tem horário. Não pergunta ao usuário. Poderia ser melhorado perguntando "Para que horário?" ao invés de inventar.

### Conclusão: Funciona 80%. TIMEOUT esporádico por retries excessivos.
