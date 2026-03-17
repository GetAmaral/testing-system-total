# Consultar Lembretes — Análise Detalhada
**Score: 2/5** | Status: 🔴 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "quais lembretes eu tenho?" | 7.1s | Só dia atual | ⚠️ |
| P2 | "lista meus lembretes" | 7.1s | Só dia atual | ⚠️ |
| P3 | "mostra meus próximos lembretes" | 9.3s | 2 semanas | ✅ |
| P4 | "meus lembretes da semana" | 9.3s | Semana | ✅ |
| P5 | "quais são meus lembretes?" | 7.1s | Só dia atual | ⚠️ |

## Bugs Encontrados

### Bug: Mostra só dia atual (60% das vezes)
- **Frequência:** 3/5 (60%)
- **Onde ocorre:** AI Agent → tool `buscar_eventos` (range de busca)
- **Padrão:** Funciona quando tem "próximos" ou "da semana". Falha quando genérico.
- **Causa raiz:** AI Agent usa TODAY como range default quando não especificado.
- **Fix:** No system prompt:
```
"meus lembretes" sem período = buscar próximos 14 dias
```

### Conclusão: Bug de UX. Precisa de regra de default no prompt.
