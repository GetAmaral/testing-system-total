# Excluir Último Gasto — Análise Detalhada
**Score: 4/5** | Status: 🟡 QUASE ESTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "apaga meu último gasto" | 11.5s | Excluiu Café | ✅ |
| P2 | "deleta o último lançamento" | 9.3s | Excluiu Bico | ✅ |
| P3 | "apaga o último registro" | 9.2s | Excluiu Comissão | ✅ |
| P4 | "remove meu último gasto registrado" | 9.3s | Excluiu Parking | ✅ |
| P5 | "apaga o último que registrei" | 11.5s | "Não encontrei" | ❌ |

## Bugs Encontrados

### Bug: "Não encontrei" após exclusão anterior (P5)
- **Frequência:** 1/5 (20%)
- **O que aconteceu:** P5.08 excluiu "Rodízio". P5.09 pediu "apaga o último que registrei". A IA tentou buscar "Rodízio" (do contexto da conversa) que já não existia.
- **Onde ocorre:** AI Agent + Redis Chat Memory
- **Causa raiz:** A IA usa o contexto da conversa (Redis) para identificar "o último". Como "Rodízio" estava no histórico recente, buscou por nome ao invés de buscar por data mais recente no banco.
- **Fix:** No prompt `excluir2`:
```
"Último gasto" = buscar com ORDER BY data_gasto DESC LIMIT 1.
NUNCA usar nome da conversa anterior. Sempre consultar o banco.
```

### Conclusão
Funciona bem quando há registros. Falha quando o contexto da conversa contém um registro já excluído.
