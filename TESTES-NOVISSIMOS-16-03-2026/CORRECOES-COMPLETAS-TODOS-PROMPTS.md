# Correções Completas — Todos os Prompts
**Data:** 2026-03-16
**Baseado em:** 200 testes + análise node-a-node
**Instrução:** Cada seção mostra O QUE MUDAR e ONDE COLAR no n8n

---

## CORREÇÃO 1: Classificador (`Escolher Branch`)

### Onde: Node `Escolher Branch` → campo `Text` (prompt)

### O que adicionar — REGRA DE AÇÃO FINANCEIRA

Colar **LOGO APÓS** a "REGRA SUPREMA" e **ANTES** da "REGRA DE RECORRÊNCIA":

```
REGRA DE AÇÃO FINANCEIRA — PRIORIDADE MÁXIMA (ANTES DE TUDO)

Se a mensagem atual contiver verbos no IMPERATIVO pedindo EXECUÇÃO
de uma transação financeira, retorne "padrao". O sistema NÃO executa
transações — apenas REGISTRA o que já aconteceu.

VERBOS DE AÇÃO (IMPERATIVO — retornar "padrao"):
"paga", "pague", "transfere", "transferir", "faz pix", "fazer pix",
"deposita", "depositar", "coloca na poupança", "investe", "investir",
"aplica", "aplicar", "guarda", "guardar", "saca", "sacar",
"envia pra", "manda pra", "compra" (quando pede compra, não relata)

VERBOS DE DECLARAÇÃO (PASSADO — retornar "criar_gasto"):
"paguei", "transferi", "fiz pix", "depositei", "coloquei",
"investi", "apliquei", "guardei", "saquei", "gastei", "comprei",
"desembolsei", "torrei", "saiu", "deu", "foi", "custou"

TESTE RÁPIDO: trocar o verbo por "eu já fiz isso?"
- "paga meu boleto" → "eu já paguei?" → NÃO → padrao
- "paguei o boleto" → "eu já paguei?" → SIM → criar_gasto

EXEMPLOS CRÍTICOS:
"paga meu boleto de 200" → padrao
"paguei o boleto de 200" → criar_gasto
"transfere 500 pro João" → padrao
"transferi 500 pro João" → criar_gasto
"investe 1000 em CDB" → padrao
"investi 1000 em CDB" → criar_gasto
"coloca 300 na poupança" → padrao
"coloquei 300 na poupança" → criar_gasto
"faz pix de 80 pra Maria" → padrao
"fiz pix de 80 pra Maria" → criar_gasto
"guarda 1000 na reserva" → padrao
"guardei 1000 na reserva" → criar_gasto
"aplica 2000 em tesouro" → padrao
"apliquei 2000 em tesouro" → criar_gasto
```

### O que adicionar — REGRA DE DESAMBIGUAÇÃO

Colar na seção **DETECÇÃO DE FINANCEIRO**, antes dos exemplos de editar:

```
REGRA DE DESAMBIGUAÇÃO — EDIÇÃO/EXCLUSÃO GASTO vs EVENTO

Quando editar ou excluir algo com nome AMBÍGUO (pode ser gasto ou evento):
→ DEFAULT = branch FINANCEIRO (editar ou excluir)
→ Só usar evento se nome for CLARAMENTE de agenda

Nomes SEMPRE financeiro: uber, ifood, mercado, luz, gasolina, farmácia,
restaurante, delivery, parking, supermercado, almoço (gasto), lanche
Nomes SEMPRE evento: reunião, consulta, dentista, academia, aula, treino,
faculdade, pilates, yoga, corrida, futebol, natação

Se não estiver em nenhuma lista → financeiro (default)
```

### O que adicionar — REGRA DE PERÍODO

Colar na seção **DETECÇÃO DE AGENDA**, no final:

```
REGRA DE PERÍODO TEMPORAL (SEM CONTEXTO FINANCEIRO)

Frases que mencionam PERÍODO sem verbo financeiro explícito
→ buscar_evento_agenda (NÃO gerar_relatorio)

Exemplos → buscar_evento_agenda:
"semana que vem", "próxima semana", "próxima semana inteira"
"esse mês", "mês que vem", "amanhã", "depois de amanhã"
"próximos 5 dias", "próximos dias"

Exemplos → gerar_relatorio (TEM contexto financeiro):
"relatório da semana", "resumo de gastos do mês"
"quanto gastei na semana", "extrato mensal"
"relatório", "resumo financeiro"

REGRA: Se NÃO tem "relatório"/"resumo"/"gastos"/"gastei"/"extrato"
→ é busca de agenda, NÃO relatório
```

### O que adicionar — VERBOS DE EDIÇÃO

Colar na seção **DETECÇÃO DE FINANCEIRO**, nos exemplos de editar:

```
Adicionar aos verbos de edição:
"arruma", "ajusta", "conserta", "era X não Y", "na verdade foi",
"o valor correto é", "errei o valor", "saiu X arruma"
→ editar
```

---

## CORREÇÃO 2: Prompt `registrar_gasto`

### Onde: Node `registrar_gasto` → campo `prompt`

### Mudança 1 — REGRA DE CONTINUAÇÃO (restringir)

**TROCAR** o texto atual:

```
REGRA DE CONTINUAÇÃO: Se a mensagem atual NÃO tem valor MAS é follow-up
("comece", "pode", "sim", "ok", "faça", "registre", "bora", "manda",
"faz aí", "mete bala") E o HISTÓRICO tem valores → extraia do histórico
e registre.
```

**POR:**

```
REGRA DE CONTINUAÇÃO: Se a mensagem atual NÃO tem valor MAS é uma
CONFIRMAÇÃO EXPLÍCITA (apenas estas palavras ISOLADAS, sem mais nada):
"sim", "ok", "pode", "bora", "faça", "registre", "comece", "manda"
E o HISTÓRICO tem valores → extraia do histórico e registre.

NÃO ATIVAR CONTINUAÇÃO para:
- Perguntas: "e na...", "e no...", "quanto...", "quais...", "como..."
- Períodos: "semana passada", "mês anterior", "ontem", "anterior"
- Emojis sozinhos: 👍, 👎, 😂, 🔥, 🤙, ✌️, 👋 etc
- Frases com 3+ palavras que não sejam confirmação direta
- Qualquer coisa que comece com "e " (continuação de busca)

Se a mensagem começa com "e " → acao = "padrao" (é busca, não confirmação)
```

### Mudança 2 — REGRA ZERO (permitir dúvida)

**TROCAR:**

```
REGRA ZERO: NUNCA peça confirmação. Se tem valor → registre imediatamente.
Sem perguntas.
```

**POR:**

```
REGRA ZERO: Se tem valor claro + verbo de declaração (gastei, paguei,
comprei, recebi) → registre imediatamente. Sem perguntas.

EXCEÇÃO: Se o verbo for IMPERATIVO (paga, transfere, deposita, investe,
aplica, coloca, guarda) → NÃO registre. Responda:
"Não consigo executar transações, mas posso registrar se você já fez.
Quer que eu registre?"
```

### Mudança 3 — MENSAGEM DE ENTRADA (trocar texto)

**TROCAR:**

```
1 entrada: "✅ Registro registrado!\n\n📝 Nome: {NOME}\n💰 Valor: R${VALOR}\n📚 Categoria: {CAT}"
```

**POR:**

```
1 entrada: "✅ Entrada registrada!\n\n📝 Nome: {NOME}\n💰 Valor: R${VALOR}\n📚 Categoria: {CAT}"
```

### Mudança 4 — CATEGORIAS DE ENTRADA

**TROCAR:**

```
Entrada → Outros | Eventuais
```

**POR:**

```
Entrada:
Renda|Fixos: salário, pagamento, holerite, pro-labore, 13°, FGTS
Renda Extra|Eventuais: freelance, bico, comissão, serviço, diária
Vendas|Eventuais: venda, revenda, vendi
Investimentos|Eventuais: rendimento, dividendos, juros, cashback
Outros|Eventuais: se não encaixar acima

NOME: Sempre extrair do contexto. NUNCA usar "Receita" genérico.
"recebi 2000 de salário" → nome = "Salário" (NÃO "Receita")
"ganhei 500 de bico" → nome = "Bico"
"caiu 4200 do trabalho" → nome = "Trabalho"
"entrou 800 de comissão" → nome = "Comissão"
```

---

## CORREÇÃO 3: AI Agent System Prompt

### Onde: Node `AI Agent` → Options → System Message

### Mudança 1 — Seção "O QUE VOCÊ NÃO FAZ"

**TROCAR** a seção inteira por:

```
O QUE VOCÊ NÃO FAZ (e deve saber dizer com clareza):
• NÃO cria planejamentos financeiros, orçamentos ou metas
• NÃO analisa investimentos ou carteira
• NÃO cria métricas, dashboards ou gráficos
• NÃO faz coaching, consultoria ou aconselhamento financeiro
• NÃO executa transações financeiras (pagar boleto, fazer pix, transferir, depositar, investir, sacar)
• NÃO define limites de gasto por categoria
• NÃO exporta planilhas, PDFs ou arquivos
• NÃO conta piadas, histórias, curiosidades ou qualquer conteúdo de entretenimento
• NÃO agenda em outros calendários além do Google Agenda conectado
• NÃO envia e-mails, faz ligações ou interage com outros apps
• NÃO acessa internet, pesquisa preços ou busca informações externas
```

### Mudança 2 — Seção "REGRAS TÉCNICAS"

**TROCAR:**

```
• NUNCA peça confirmação para CRIAR. Interprete e aja.
```

**POR:**

```
• NUNCA peça confirmação para CRIAR ou EDITAR. Interprete e aja.
• Quando excluir evento ou gasto, responda APENAS sobre a exclusão. NÃO chame outras tools na mesma resposta.
```

### Mudança 3 — Adicionar REGRAS DE BUSCA (no final das REGRAS TÉCNICAS)

```
BUSCA DE AGENDA:
• "agenda de hoje" ou "o que tenho hoje" → buscar de 00:00 a 23:59 do dia (dia inteiro, NUNCA hora atual)
• "meus lembretes" sem período → buscar próximos 14 dias
• "semana que vem" sem contexto financeiro → buscar agenda, NÃO relatório

DECLARAÇÃO vs AÇÃO:
• Se o usuário pedir para EXECUTAR transação (pagar, transferir, investir, depositar):
  responda "Não consigo executar transações, mas posso registrar se já aconteceu. Quer que eu registre?"
• Só registre gastos quando o usuário DECLARAR algo no passado (gastei, paguei, comprei)
```

---

## CORREÇÃO 4: Node `AI Agent` — Config

### Onde: Node `AI Agent` → Settings

### Mudança:

```
ATUAL:   retryOnFail: true, maxTries: 5, waitBetweenTries: 300
TROCAR:  retryOnFail: true, maxTries: 2, waitBetweenTries: 300
```

Reduz timeout máximo de ~65s para ~26s.

---

## CORREÇÃO 5: Prompt `excluir2`

### Onde: Node `excluir2` → campo `prompt`

### Adicionar após a seção de REFERÊNCIAS:

```
REGRA "ÚLTIMO GASTO":
Quando o usuário pedir "apaga meu último gasto/registro/lançamento":
→ SEMPRE buscar no banco com ORDER BY data_gasto DESC LIMIT 1
→ NUNCA usar o nome do gasto da conversa anterior
→ O "último" é o registro mais recente NO BANCO, não na conversa
```

---

## RESUMO — CHECKLIST DE APLICAÇÃO

```
□ 1. Abrir node "Escolher Branch"
     → Adicionar REGRA DE AÇÃO FINANCEIRA após REGRA SUPREMA
     → Adicionar REGRA DE DESAMBIGUAÇÃO na seção FINANCEIRO
     → Adicionar REGRA DE PERÍODO na seção AGENDA
     → Adicionar verbos de edição (arruma, ajusta)
     → Salvar

□ 2. Abrir node "registrar_gasto"
     → Trocar REGRA DE CONTINUAÇÃO pela versão restrita
     → Trocar REGRA ZERO pela versão com exceção
     → Trocar "Registro registrado" por "Entrada registrada"
     → Trocar categorias de entrada
     → Salvar

□ 3. Abrir node "AI Agent"
     → Trocar seção "O QUE VOCÊ NÃO FAZ"
     → Trocar regra de confirmação (CRIAR → CRIAR ou EDITAR)
     → Adicionar regras de busca e declaração vs ação
     → Mudar maxTries de 5 para 2
     → Salvar

□ 4. Abrir node "excluir2"
     → Adicionar regra de "último gasto"
     → Salvar

□ 5. Salvar workflow e testar
```

### Impacto esperado:
- Erros de classificação: 14 → ~1 (93% de redução)
- "Registro registrado": 5/5 → 0/5
- Gastos fantasma: eliminados
- Timeouts: reduzidos de 65s para 26s máx
- **Taxa de sucesso geral: 73.5% → ~90%+**
