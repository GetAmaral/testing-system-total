# Cenarios Comuns — Como Aplicar a Esteira

## Cenario 1: Feature Nova

**Exemplo**: "Vou adicionar filtro de categoria no financeiro"

```
@guardian

1. *snapshot pre-filtro-categoria
2. (abro N8N DEV, adiciono nodes, mudo prompts, testo)
3. *snapshot pos-filtro-categoria
4. *diff --latest
   → Vejo: Financeiro - Total tem 1 node novo, 2 conexoes novas, prompt mudou
5. *spec "Adicionei filtro de categoria no buscar gastos do financeiro"
6. *audit-spec --auto
   → Watson simula "gastos de alimentacao" no DEV
   → Veredicto: GO
7. *pre-deploy
   → Checklist: 23 URLs + 8 credentials + pinData = 34 correcoes
8. (aplico as 34 correcoes, faco deploy)
9. *validate-prod
   → ALL_CLEAR
```

**Tempo total**: ~1h30 (incluindo desenvolvimento)

---

## Cenario 2: Bug Fix Rapido

**Exemplo**: "O calendario nao esta retornando eventos do dia certo"

```
@guardian

1. *snapshot pre-fix-calendario
2. (abro N8N DEV, corrijo o node de data, testo)
3. *snapshot pos-fix-calendario
4. *diff --latest
   → Vejo: Calendar WebHooks - 1 node modificado (parametro de data corrigido)
   → Risco: LOW
5. *spec "Corrigi parametro de data no Calendar WebHooks que buscava dia errado"
6. *audit-spec --auto
   → Veredicto: GO (fix pontual, sem regressao)
7. *pre-deploy
   → Checklist: 5 URLs + 0 credentials = 5 correcoes (so neste workflow)
8. (aplico as 5 correcoes, faco deploy APENAS do Calendar WebHooks)
9. *validate-prod
   → ALL_CLEAR
```

**Tempo total**: ~30 min

---

## Cenario 3: Mudanca de Prompt AI

**Exemplo**: "Quero melhorar o prompt do classificador para entender girias"

```
@guardian

1. *snapshot pre-prompt-girias
2. (abro N8N DEV, mudo o system message do AI Agent)
3. *snapshot pos-prompt-girias
4. *diff --latest
   → DESTAQUE: PROMPT mudou no Fix Conflito v2
   → Diff lado-a-lado do prompt antigo vs novo
   → Risco: CRITICAL (prompts AI sao logica de negocio)
5. *spec "Atualizei prompt do classificador para entender girias como 'torrei', 'conto'"
6. *audit-spec --auto
   → Watson simula: "torrei 60 conto no bar"
   → Verifico se classificou como criar_gasto
   → Veredicto: GO
7. *pre-deploy
   → Checklist: URLs + credentials + pinData
8. (faco deploy)
9. *validate-prod
   → ALL_CLEAR
```

**Tempo total**: ~45 min

---

## Cenario 4: Refatoracao (muitas mudancas)

**Exemplo**: "Vou reorganizar o fluxo premium inteiro"

```
@guardian

1. *snapshot pre-refactor-premium
2. (trabalho no N8N DEV por horas/dias, fazendo mudancas grandes)
   DICA: se o trabalho for longo, tire snapshots intermediarios:
   *snapshot wip-premium-dia1
   *snapshot wip-premium-dia2
3. *snapshot pos-refactor-premium
4. *diff pre-refactor-premium pos-refactor-premium
   → Diff grande: muitos nodes, conexoes, prompts
   → Risco: HIGH ou CRITICAL
5. *spec "Refatorei todo o fluxo premium: separei tools, simpliquei prompts, adicionei error handling"
6. *audit-spec --auto
   → Testes mais extensos (broad, nao quick)
   → Verificar TODAS as features premium
   → Veredicto: pode ser CONDICIONAL (ressalvas aceitaveis)
7. *pre-deploy
   → Checklist GRANDE: muitas correcoes
8. (deploy cuidadoso, item por item)
9. *validate-prod
   → Monitorar por mais tempo apos deploy
```

**Tempo total**: horas/dias de desenvolvimento + ~1h de deploy

---

## Cenario 5: Deploy sem mudanca no DEV (so re-deploy)

**Exemplo**: "Preciso re-deployar os mesmos JSONs que ja estao no DEV"

```
@guardian

1. *snapshot estado-atual     (para ter registro)
2. *pre-deploy                (gerar checklist com estado atual)
3. (aplico correcoes, faco deploy)
4. *validate-prod
```

Nao precisa de diff nem spec nem teste — so o checklist e a validacao.

---

## Cenario 6: So quero ver o que mudou (sem deployar)

**Exemplo**: "Outro dev mexeu no DEV, quero entender o que ele fez"

```
@guardian

1. *snapshot agora
2. *diff agora {snapshot-anterior}
   ou *diff --latest (se ja tem snapshot anterior)
3. (leio o diff e entendo as mudancas)
```

Nao precisa de spec, teste, checklist nem deploy. So snapshot + diff.

---

## Cenario 7: Emergencia — Deploy quebrou

**Ver**: [04-EMERGENCIA.md](04-EMERGENCIA.md)

---

## Qual cenario usar?

| Situacao | Fases da esteira | Cenario |
|----------|-----------------|---------|
| Feature nova | TODAS (0-10) | 1 |
| Bug fix rapido | TODAS (0-10) mas mais rapido | 2 |
| Mudanca de prompt | TODAS (0-10) com atencao ao diff | 3 |
| Refatoracao grande | TODAS (0-10) com snapshots intermediarios | 4 |
| Re-deploy | 1, 7, 8, 9 | 5 |
| So ver mudancas | 1, 4 | 6 |
| Emergencia | Rollback | 7 |

---

## Dicas

### Nomes de snapshot bons vs ruins

| Ruim | Bom | Por que |
|------|-----|---------|
| `pre-mudanca` | `pre-filtro-categoria-financeiro` | Especifico, sei o que era |
| `teste` | `pos-fix-data-calendario-v2` | Descritivo, com versao |
| `aaa` | `pre-v3.2-prompt-girias` | Inclui versao e contexto |

### Quando tirar snapshots extras

- Se o trabalho vai durar mais de 1 dia: snapshot diario (`wip-dia1`, `wip-dia2`)
- Se voce vai testar uma abordagem arriscada: snapshot antes (`pre-experimento-x`)
- Se outra pessoa mexeu no DEV: snapshot imediato (`checkpoint-apos-fulano`)

### Quando pular o teste (Fase 6)

Quase nunca. Mas se for:
- Mudanca cosmetica (posicao de node, nota, descricao): pode pular
- Re-deploy identico (mesmo JSON): pode pular

Na duvida, teste. Custa 5 minutos e pode salvar horas.
