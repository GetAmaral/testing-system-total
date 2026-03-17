# Editar Nome de Gasto — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "muda nome do almoço pra restaurante" | 11.9s | CRIOU EVENTO | ❌ |
| P2 | "troca ifood pra delivery" | 13.6s | Renomeou correto | ✅ |
| P3 | "renomeia lanche pra lanchonete" | 7.1s | Renomeou correto | ✅ |
| P4 | "muda estacionamento pra parking" | 7.0s | Renomeou correto | ✅ |
| P5 | "troca janta pra rodízio" | 7.1s | Renomeou correto | ✅ |

## Bugs Encontrados

### Bug: Confusão gasto vs evento (P1)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** Classificador `Escolher Branch`
- **O que aconteceu:** "muda nome do almoço pra restaurante" foi classificado como `editar_evento_agenda` ao invés de `editar` (financeiro). A IA respondeu "atualizei seu evento" com horário 16h23 — criou um EVENTO chamado "restaurante".
- **Causa raiz:** "almoço" é ambíguo — pode ser um gasto (almoço R$45) ou um evento na agenda (almoço às 12h). O classificador não tem contexto do que foi criado recentemente.
- **Fix:** No classificador, quando ambíguo entre gasto e evento na edição, priorizar gasto (mais comum):
```
Se ambíguo entre editar gasto e editar evento:
→ verificar histórico recente
→ se nome existe como gasto → editar gasto
→ default → editar gasto (mais frequente)
```

### Conclusão
Funciona bem com nomes não-ambíguos (ifood, estacionamento, janta). Falha quando o nome pode ser gasto ou evento.
