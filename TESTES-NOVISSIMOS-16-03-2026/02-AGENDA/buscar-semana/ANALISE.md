# Buscar Agenda da Semana — Análise Detalhada
**Score: 3/5** | Status: 🔴 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "o que tenho essa semana?" | 7.1s | Listou corretamente | ✅ |
| P2 | "como tá minha semana?" | 11.5s | Listou corretamente | ✅ |
| P3 | "próximos 5 dias" | 7.1s | Listou corretamente | ✅ |
| P4 | "semana que vem" | 7.1s | RELATÓRIO FINANCEIRO | ❌ |
| P5 | "próxima semana inteira" | 4.8s | RELATÓRIO FINANCEIRO | ❌ |

## Bugs Encontrados

### Bug: Classificador interpreta como relatório financeiro
- **Frequência:** 2/5 (40%)
- **Onde ocorre:** Classificador `Escolher Branch`
- **Causa raiz:** Frases curtas sobre período ("semana que vem", "próxima semana inteira") sem verbo de agenda explícito são classificadas como `gerar_relatorio`. O classificador não tem regra para distinguir "semana que vem" (agenda) de "relatório da semana" (financeiro).
- **Padrão:** Funciona quando tem contexto de agenda ("o que tenho", "como tá minha", "próximos X dias"). Falha quando é só o período.
- **Fix:** No classificador:
```
"semana que vem", "próxima semana", "esse mês" (sem "gastos/gastei/financeiro")
→ buscar_evento_agenda (NÃO gerar_relatorio)
```

### Conclusão: Bug no classificador. Frases com contexto de agenda funcionam, sem contexto viram relatório.
