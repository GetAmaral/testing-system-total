# Buscar Agenda do Dia — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "o que tenho pra hoje?" | 7.1s | "Não encontrei eventos" | ❌ |
| P2 | "minha agenda de amanhã" | 7.1s | Listou corrida | ✅ |
| P3 | "agenda do dia" | 7.1s | Listou Buscar Encomenda | ✅ |
| P4 | "meus compromissos de hoje" | 7.1s | Listou 2 eventos | ✅ |
| P5 | "agenda de hoje" | 4.9s | Listou 3 eventos | ✅ |

## Bugs Encontrados

### Bug: "Não encontrei" quando tinha eventos (P1)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** AI Agent → tool `buscar_eventos`
- **Causa raiz provável:** Na P1, a IA pode ter usado a hora atual como início da busca ao invés de 00:00:00. Eventos que já passaram no dia não foram retornados. Ou: os eventos recorrentes recém-criados (academia) não tinham instância expandida para hoje.
- **Fix:** No system prompt do AI Agent:
```
"agenda de hoje" → data_inicio = "YYYY-MM-DD 00:00:00-03"
Nunca usar hora atual como início. Sempre dia inteiro.
```

### Conclusão: Funciona 80% das vezes. Bug esporádico de timezone/range.
