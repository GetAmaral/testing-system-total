# Criar Receita — Análise Detalhada
**Score: 0/5** | Status: 🔴 CONSISTENTEMENTE QUEBRADO

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "recebi 2000 de salário" | 7.3s | "Registro registrado!" Cat Outros | ⚠️ |
| P2 | "ganhei 500 de bico" | 7.2s | "Registro registrado!" Cat Outros | ⚠️ |
| P3 | "entrou 800 de comissão" | 7.1s | "Registro registrado!" Cat Outros | ⚠️ |
| P4 | "recebi 3500 do meu salário" | 4.9s | "Registro registrado!" Cat Outros | ⚠️ |
| P5 | "caiu 4200 na conta do trabalho" | 7.1s | Nome genérico "Receita" Cat Outros | ⚠️ |

## Bugs Encontrados

### Bug 1: "Registro registrado!" (texto redundante)
- **Frequência:** 5/5 (100%)
- **Onde ocorre:** Node `registrar_gasto` no workflow Fix Conflito v2
- **Causa raiz:** O prompt não diferencia mensagem de sucesso para entrada vs saída. Não existe instrução como "Se for entrada, diga 'Entrada registrada!'"
- **Fix:** Adicionar ao prompt:
```
Se entra_sai_gasto = "entrada": "✅ Entrada registrada!"
Se entra_sai_gasto = "saida": "✅ Gasto registrado!"
```

### Bug 2: Categoria sempre "Outros"
- **Frequência:** 5/5 (100%)
- **Onde ocorre:** Mesmo node `registrar_gasto`
- **Causa raiz:** Não existe mapeamento de categorias para receitas no prompt. O prompt só tem categorias para gastos.
- **Fix:** Adicionar ao prompt:
```
Categorias para ENTRADAS:
- Salário, pagamento → "Renda"
- Freelance, bico, serviço, comissão → "Renda Extra"
- Venda → "Vendas"
- Outros → "Outros"
```

### Bug 3: Nome genérico "Receita" (P5)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** O LLM não inferiu nome de "caiu 4200 na conta do trabalho"
- **Causa raiz:** O prompt diz `Sem nome → "Receita" (entrada)` — deveria usar o contexto da frase
- **Fix:** Instruir a IA a extrair nome do contexto: "caiu na conta do trabalho" → nome = "Trabalho"

### Conclusão
Feature com 0% de acerto em 5 passadas. Precisa de correção urgente no prompt `registrar_gasto`.
