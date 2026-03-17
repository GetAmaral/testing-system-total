# Editar Valor de Gasto — Análise Detalhada
**Score: 3/5** | Status: 🟡 INSTÁVEL

## Resultados por Passada

| Passada | Input | Latência | Resposta | Status |
|---------|-------|----------|----------|--------|
| P1 | "almoço foi 52, corrige" | 23.5s | R$52 atualizado | ✅ |
| P2 | "ifood foi 75, não 60. arruma" | 15.9s | R$75 atualizado | ✅ |
| P3 | "lanche custou 28, não 25" | 42.3s | R$28 atualizado | ⚠️ |
| P4 | "estacionamento foi 22" | 15.9s | R$22 atualizado | ✅ |
| P5 | "a janta saiu 110, arruma pra mim" | 15.9s | CRIOU NOVO gasto R$110 | ❌ |

## Bugs Encontrados

### Bug 1: Edição cria novo gasto ao invés de editar (P5)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** Classificador `Escolher Branch`
- **Causa raiz:** "arruma pra mim" não está na lista de verbos de edição do classificador. O classificador viu "saiu 110" e classificou como `criar_gasto`.
- **Verbos reconhecidos como edição:** "corrige", "muda", "altera", "edita"
- **Verbos NÃO reconhecidos:** "arruma", "ajusta", "conserta"
- **Fix:** Adicionar ao classificador:
```
REGRA DE EDIÇÃO: "arruma", "ajusta", "conserta", "era X não Y",
"na verdade foi", "o valor correto é" → branch = "editar"
```

### Bug 2: Latência alta (42s em P3)
- **Frequência:** 1/5 (20%)
- **Onde ocorre:** AI Agent fazendo 2 tool calls (buscar + editar) via Redis
- **Causa raiz:** Cada tool call passa por ~21 nodes Redis. Redis na Europa adiciona ~300ms por node. 2 tool calls = ~12s só de Redis + tempo da IA.
- **Fix:** Redis local eliminaria ~10s da latência

### Conclusão
Funciona na maioria dos casos mas é frágil com verbos informais ("arruma"). Latência alta é sistêmica.
