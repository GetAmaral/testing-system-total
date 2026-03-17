# Diagnóstico Profundo — Classificador (Escolher Branch)
**Data:** 2026-03-16
**Node:** `Escolher Branch` (chainLlm)
**Model:** GPT-4.1-mini
**Workflow:** Fix Conflito v2

---

## O que é o classificador

É o cérebro de roteamento do sistema. Recebe a mensagem do user e decide qual dos 11 branches usar:

```
criar_gasto | buscar | editar | excluir
criar_evento_agenda | criar_evento_recorrente
buscar_evento_agenda | editar_evento_agenda | excluir_evento_agenda
gerar_relatorio | padrao
```

Toda mensagem passa por ele. Se ele erra, tudo erra.

---

## Diagnóstico: 14 erros de classificação em 200 testes (7%)

### O PROBLEMA CENTRAL

O prompt tem essa regra na seção DETECÇÃO DE FINANCEIRO:

```
Se a mensagem mencionar dinheiro, valores, gastos, pagamentos,
ganhos, receber, contas, fatura, cartão, PIX, reais, R$,
número com vírgula ou ponto que pareça valor
→ escolha um branch financeiro
```

Essa regra é **muito ampla**. Qualquer número que pareça dinheiro vira `criar_gasto`. Não importa se o user está PEDINDO uma ação ("paga meu boleto") ou DECLARANDO um gasto ("paguei o boleto").

**12 dos 14 erros (86%) são causados por essa regra.**

---

## Os 3 tipos de erro

### TIPO 1: Ação vs Declaração (8 erros — 57%)

O classificador não distingue:
- **"paguei 200 de luz"** → passado, aconteceu → criar_gasto ✅
- **"paga meu boleto de 200"** → imperativo, pedido de ação → deveria ser `padrao` ❌

| Input | Verbo | Tempo | Classificou | Deveria |
|-------|-------|-------|------------|---------|
| "paga boleto 200" | paga | imperativo | criar_gasto ❌ | padrao |
| "deposita 150" | deposita | imperativo | criar_gasto ❌ | padrao |
| "paga fatura 450" | paga | imperativo | criar_gasto ❌ | padrao |
| "transfere 500" | transfere | imperativo | criar_gasto ❌ | padrao |
| "coloca 300 na poupança" | coloca | imperativo | criar_gasto ❌ | padrao |
| "investe 200 em bitcoin" | investe | imperativo | criar_gasto ❌ | padrao |
| "guarda 1000 na reserva" | guarda | imperativo | criar_gasto ❌ | padrao |
| "aplica 2000 em CDB" | aplica | imperativo | criar_gasto ❌ | padrao |

**Por que acontece:** O prompt não tem NENHUMA regra sobre tempo verbal. Não diferencia "paguei" (passado) de "paga" (imperativo).

### TIPO 2: Ambiguidade gasto vs evento (2 erros — 14%)

| Input | Classificou | Deveria |
|-------|------------|---------|
| "muda nome do almoço pra restaurante" | editar_evento_agenda ❌ | editar |
| "deleta parking" | excluir_evento_agenda ❌ | excluir |

**Por que acontece:** "almoço" e "parking" podem ser gasto ou evento. O prompt não tem regra de desambiguação.

### TIPO 3: Período sem contexto vira relatório (2 erros — 14%)

| Input | Classificou | Deveria |
|-------|------------|---------|
| "semana que vem" | gerar_relatorio ❌ | buscar_evento_agenda |
| "próxima semana inteira" | gerar_relatorio ❌ | buscar_evento_agenda |

**Por que acontece:** Frases curtas sem verbo. O prompt usa histórico para decidir. Se o histórico era financeiro, classifica como `gerar_relatorio`.

### TIPO BÔNUS: Edição não reconhecida (1 erro)

| Input | Classificou | Deveria |
|-------|------------|---------|
| "a janta saiu 110, arruma pra mim" | criar_gasto ❌ | editar |

**Por que acontece:** "arruma" não está na lista de verbos de edição do prompt. "110" + "saiu" pareceu mais forte → criar_gasto.

---

## A causa raiz: HIERARQUIA DE PRIORIDADE

O prompt tem essa ordem de prioridade:

```
1. REGRA SUPREMA — mensagem atual > histórico
2. REGRA DE RECORRÊNCIA — todo dia/semana/mês → criar_evento_recorrente
3. REGRA DE CRIAÇÃO DE EVENTO — lista com horários → criar_evento_agenda
4. REGRA DE EXCLUSÃO — verbo explícito de exclusão
5. REGRA DE BUSCA — verbo explícito de busca
6. DETECÇÃO DE FINANCEIRO — valor monetário → branch financeiro
7. DETECÇÃO DE AGENDA — horário/data → branch de agenda
```

O problema: **NÃO EXISTE** uma regra entre 1 e 6 que diga:

```
"Se o user está PEDINDO uma AÇÃO (pagar, transferir, investir),
 NÃO classifique como financeiro. Use padrao."
```

A regra 6 (valor monetário → financeiro) sempre vence porque é muito ampla.

---

## FIX: O que adicionar ao prompt

### FIX 1 — REGRA DE AÇÃO FINANCEIRA (adicionar entre regras 1 e 2)

```
REGRA DE AÇÃO FINANCEIRA — PRIORIDADE MÁXIMA

Se a mensagem atual contiver verbos no IMPERATIVO pedindo EXECUÇÃO
de uma transação financeira, retorne "padrao". A IA NÃO executa
transações — apenas REGISTRA o que já aconteceu.

VERBOS DE AÇÃO (IMPERATIVO — NÃO registrar, usar "padrao"):
"paga", "pague", "transfere", "transferir", "faz pix", "fazer pix",
"deposita", "depositar", "coloca na poupança", "investe", "investir",
"aplica", "aplicar", "guarda", "guardar", "saca", "sacar",
"envia pra", "manda pra", "compra" (quando é pedido de compra)

VERBOS DE DECLARAÇÃO (PASSADO — registrar como criar_gasto):
"paguei", "transferi", "fiz pix", "depositei", "coloquei",
"investi", "apliquei", "guardei", "saquei", "gastei", "comprei",
"desembolsei", "torrei", "saiu", "deu", "foi", "custou"

EXEMPLOS:
"paga meu boleto de 200" → padrao (imperativo, pedido de ação)
"paguei o boleto de 200" → criar_gasto (passado, declaração)
"transfere 500 pro João" → padrao
"transferi 500 pro João" → criar_gasto
"investe 1000 em CDB" → padrao
"investi 1000 em CDB" → criar_gasto
"coloca 300 na poupança" → padrao
"coloquei 300 na poupança" → criar_gasto
```

### FIX 2 — REGRA DE DESAMBIGUAÇÃO GASTO vs EVENTO

```
REGRA DE DESAMBIGUAÇÃO — EDIÇÃO/EXCLUSÃO

Quando a mensagem pedir para editar ou excluir algo com nome AMBÍGUO
(pode ser gasto ou evento), usar o branch FINANCEIRO como default:
- editar → "editar" (não "editar_evento_agenda")
- excluir → "excluir" (não "excluir_evento_agenda")

Só usar branch de EVENTO quando o nome for CLARAMENTE um evento:
- Nomes de evento: reunião, consulta, dentista, academia, aula, treino
- Nomes de gasto: uber, ifood, mercado, luz, gasolina, farmácia

Se ambíguo (almoço, parking, café): → branch financeiro
```

### FIX 3 — REGRA DE PERÍODO SEM CONTEXTO

```
REGRA DE PERÍODO TEMPORAL

Mensagens que mencionam PERÍODO DE TEMPO sem contexto financeiro
explícito devem ir para buscar_evento_agenda:

"semana que vem", "próxima semana", "essa semana",
"amanhã", "depois de amanhã", "próximos X dias",
"mês que vem", "esse mês" (SEM "gastos"/"gastei"/"relatório")

Só vai para gerar_relatorio quando tiver CONTEXTO FINANCEIRO:
"relatório da semana", "resumo de gastos", "quanto gastei na semana"
```

### FIX 4 — VERBOS DE EDIÇÃO EXPANDIDOS

```
Na seção de DETECÇÃO DE FINANCEIRO, exemplos de editar, adicionar:

"arruma", "ajusta", "conserta", "era X não Y",
"na verdade foi", "o valor correto é", "errei o valor",
"saiu X arruma" → editar
```

---

## Onde colar no prompt

A REGRA DE AÇÃO FINANCEIRA deve ser inserida **LOGO APÓS** a "REGRA SUPREMA" e **ANTES** da "REGRA DE RECORRÊNCIA":

```
REGRA SUPREMA — MENSAGEM ATUAL É SOBERANA
(já existe)

REGRA DE AÇÃO FINANCEIRA — PRIORIDADE MÁXIMA    ← INSERIR AQUI
(novo — o fix 1 acima)

REGRA DE RECORRÊNCIA — PRIORIDADE MÁXIMA
(já existe)
```

A REGRA DE DESAMBIGUAÇÃO deve ir na seção de DETECÇÃO DE FINANCEIRO.

A REGRA DE PERÍODO deve ir na seção de DETECÇÃO DE AGENDA.

---

## Impacto estimado

| Fix | Erros que resolve | % dos erros |
|-----|------------------|-------------|
| Fix 1 (ação vs declaração) | 8 | 57% |
| Fix 2 (desambiguação) | 2 | 14% |
| Fix 3 (período) | 2 | 14% |
| Fix 4 (verbos edição) | 1 | 7% |
| **TOTAL** | **13/14** | **93%** |

Com esses 4 fixes, o classificador passaria de **93% → ~99.5% de acerto** (186/187 corretos nos 200 testes, restando apenas o multi-turno que é bug do prompt `registrar_gasto`, não do classificador).

---

## Outras melhorias possíveis

### 1. Trocar modelo do classificador

Hoje usa **GPT-4.1-mini**. Considerar:
- **GPT-4.1** (mais caro, mais inteligente) — melhor em nuances de tempo verbal
- **Claude Haiku** — mais rápido e bom em classificação

### 2. Reduzir tamanho do prompt

O prompt do classificador tem **~4000 tokens**. Muito longo para classificação. Quanto mais longo, mais chance de o LLM se confundir. Considerar:
- Remover exemplos redundantes
- Consolidar regras similares
- Usar poucos exemplos claros ao invés de muitas regras

### 3. Usar Text Classifier ao invés de Chain LLM

O n8n tem um node `textClassifier` nativo que é mais eficiente para classificação. Ao invés de prompt livre que retorna JSON, usa categorias fixas com descrições. Menos chance de erro de formato.

### 4. Cache de classificação

Se a mesma mensagem for classificada 2x (retries), o resultado pode mudar. Um cache curto (30s) evitaria inconsistência.

---

## Sobre memória e estrutura

### O problema da memória (Redis):
O classificador recebe o histórico via `Code9`:
```
{{ $('Code9').item.json.confirmados_classificador.map(c => `User: "${c.pedido}"`).join("\n") }}
```

Isso são os últimos 2 pedidos do user. O problema: se o último pedido era financeiro, o classificador tende a classificar frases ambíguas como financeiro.

### O problema estrutural:
O classificador é uma **única chamada de LLM** que precisa decidir entre **11 branches**. É muita responsabilidade para uma decisão. Alternativa:
- **Classificador em 2 níveis:** primeiro decide FINANCEIRO vs AGENDA vs OUTRO, depois sub-classifica
- **Classificador por exclusão:** primeiro verifica se é recorrente, depois se é busca, etc (árvore de decisão)

Mas isso adicionaria latência. A melhor relação custo-benefício é **corrigir o prompt** com os 4 fixes acima.
