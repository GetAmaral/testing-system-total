# Backlog de Bugs — Diagnóstico Profundo
**Data:** 2026-03-16
**Baseado em:** 200 testes (5 passadas x 40 ações)
**Método:** Análise cruzada dos resultados com código-fonte dos workflows n8n

---

## BUG #1: Ação vs Declaração — 1/5 confiável (CRÍTICO)

### Evidências:
```
P1.29: "paga meu boleto de 200"        → ✅ Gasto registrado! R$200 Boleto
P3.29: "deposita 150 na minha conta"   → ✅ Registro registrado! R$150 Depósito
P4.29: "paga a fatura do cartão de 450" → ✅ Gasto registrado! R$450 Fatura
P5.29: "transfere 500 pra poupança"    → ✅ Gasto registrado! R$500 Transferência
P2.29: "faz pix de 80 pra Maria"      → Recusou ✅ (ÚNICA VEZ)
```

### Diagnóstico — Onde acontece no workflow:

**Workflow:** Fix Conflito v2
**Node:** `Escolher Branch` (classificador LLM)

O classificador recebe a mensagem e decide qual branch usar. Quando o user diz "paga meu boleto de 200", o classificador vê um valor monetário (200) e classifica como `criar_gasto`.

O prompt do classificador diz:
```
Se a mensagem atual contiver um VERBO DE ACAO + OBJETO CLARO,
classifique SOMENTE pela mensagem atual.
```

O problema: "paga" é verbo de ação + "boleto de 200" tem valor monetário → classificador interpreta como `criar_gasto`.

Depois, no node `registrar_gasto`, o prompt diz:
```
REGRA ZERO: NUNCA peça confirmação. Se tem valor → registre imediatamente.
```

Essa REGRA ZERO impede qualquer questionamento. Se tem valor → registra.

### Causa raiz:
1. **Classificador** não distingue ação (imperativo) de declaração (passado)
2. **Prompt de registro** tem REGRA ZERO que impede confirmação
3. Não existe nenhuma lista de verbos que devem ser recusados

### Fix — 2 alterações:

**1. No classificador (`Escolher Branch`)**, adicionar:
```
REGRA DE AÇÃO FINANCEIRA — PRIORIDADE ALTA
Se a mensagem contém verbos no IMPERATIVO pedindo EXECUÇÃO de transação:
"paga", "transfere", "faz pix", "deposita", "coloca na poupança",
"envia pra", "manda pra", "passa pra", "saca", "aplica em"
→ branch = "padrao" (NÃO é criar_gasto)

EXCEÇÃO: verbos no PASSADO são gastos legítimos:
"paguei", "transferi", "fiz pix", "depositei", "coloquei",
"gastei", "comprei", "desembolsei"
→ branch = "criar_gasto"
```

**2. No AI Agent system prompt**, adicionar:
```
REGRA: Se o usuário pedir para EXECUTAR uma transação (pagar, transferir, fazer pix),
responda: "Não consigo executar transações, mas posso registrar se você já fez.
Quer que eu registre?"
```

### Por que P2.29 acertou:
Na passada 2, o contexto da conversa era diferente — o user tinha acabado de excluir um gasto. O AI Agent (não o classificador) recebeu a mensagem e, com contexto diferente, recusou. Isso mostra que o comportamento é inconsistente porque depende do estado da conversa.

---

## BUG #2: Investimento/Poupança registrado como gasto — 1/5 confiável (CRÍTICO)

### Evidências:
```
P1.30: "coloca 300 na poupança"           → ✅ Registro registrado! R$300
P2.30: "investe 200 em bitcoin"           → ✅ Gasto registrado! R$200
P4.30: "guarda 1000 na reserva"           → ✅ Gasto registrado! R$1000
P5.30: "aplica 2000 em CDB"              → ✅ Gasto registrado! R$2000
P3.30: "compra 3 bitcoins pra mim"       → Recusou ✅ (ÚNICA VEZ)
```

### Diagnóstico:

Mesmo fluxo do Bug #1. O classificador vê valor monetário → `criar_gasto`. Não existe branch para "investimento" nem lógica para recusar.

**Tabela `investments` existe no Supabase** mas não é usada por nenhum workflow. O sistema inteiro ignora investimentos.

### Causa raiz:
1. Classificador não tem branch para investimento
2. Tabela `investments` existe mas não tem workflow
3. Prompt de registro não filtra investimentos

### Fix:
No classificador, adicionar à regra de ação financeira:
```
"investe", "aplica", "coloca na poupança", "guarda na reserva",
"compra bitcoin/ações/CDB/tesouro"
→ branch = "padrao"
```

No AI Agent system prompt, na seção "O QUE VOCÊ NÃO FAZ":
```
• NÃO executa investimentos, transferências entre contas ou depósitos
```

---

## BUG #3: Receita sempre "Registro registrado" + Cat Outros — 0/5 (PERSISTENTE)

### Evidências:
```
P1.02: "recebi 2000 de salário"         → "Registro registrado!" Cat Outros
P2.02: "ganhei 500 de bico"             → "Registro registrado!" Cat Outros
P3.02: "entrou 800 de comissão"         → "Registro registrado!" Cat Outros
P4.02: "recebi 3500 do meu salário"     → "Registro registrado!" Cat Outros
P5.02: "caiu 4200 na conta do trabalho" → "Registro registrado!" Nome "Receita" Cat Outros
```

### Diagnóstico:

**Workflow:** Fix Conflito v2
**Node:** `registrar_gasto` (prompt de registro financeiro)

O prompt diz:
```
Sem nome → "Despesa" (saída) ou "Receita" (entrada)
```

Mas NÃO define:
- Qual texto usar na confirmação para entradas ("Entrada registrada" vs "Registro registrado")
- Categorias específicas para receitas (Renda, Freelance, etc)

A mensagem de confirmação vem do próprio LLM que gera o JSON de resposta. O LLM usa "Registro registrado" por conta própria porque o prompt não instrui texto específico para entradas.

### Causa raiz:
1. Prompt `registrar_gasto` não diferencia mensagem de sucesso para entrada vs saída
2. Não há lista de categorias para receitas (só para gastos)
3. O nome genérico "Receita" é usado quando o LLM não infere nome

### Fix — No prompt `registrar_gasto`:
```
MENSAGEM DE SUCESSO:
- Se entra_sai_gasto = "saida": "✅ Gasto registrado!"
- Se entra_sai_gasto = "entrada": "✅ Entrada registrada!"
NUNCA use "Registro registrado".

CATEGORIAS PARA ENTRADAS:
- Salário, pagamento, holerite → Categoria: "Renda"
- Freelance, bico, serviço → Categoria: "Renda Extra"
- Comissão, bonificação → Categoria: "Renda Extra"
- Venda, revenda → Categoria: "Vendas"
- Outros → Categoria: "Outros"

NOME: Sempre use o que o usuário disse.
"recebi 2000 de salário" → nome = "Salário" (não "Receita")
"ganhei 500 de bico" → nome = "Bico"
```

---

## BUG #4: "Semana que vem" vira relatório financeiro — 3/5

### Evidências:
```
P4.14: "semana que vem" → "Vou preparar um relatório financeiro da semana que vem" ❌
P5.14: "próxima semana inteira" → "Vou preparar seu relatório financeiro" ❌
P1.14: "o que tenho essa semana?" → Listou agenda ✅
P2.14: "como tá minha semana?" → Listou agenda ✅
P3.14: "próximos 5 dias" → Listou agenda ✅
```

### Diagnóstico:

**Node:** `Escolher Branch` (classificador)

Quando a mensagem é curta e ambígua ("semana que vem", "próxima semana inteira"), o classificador não tem contexto suficiente para decidir entre `buscar_evento_agenda` e `gerar_relatorio`.

O prompt do classificador diz:
```
REGRA SUPREMA — MENSAGEM ATUAL E SOBERANA
Se a mensagem atual contiver um VERBO DE ACAO + OBJETO CLARO,
classifique SOMENTE pela mensagem atual.
```

"Semana que vem" não tem verbo de ação, então o classificador usa o histórico. Se a conversa anterior era sobre gastos, ele classifica como `gerar_relatorio`.

### Causa raiz:
O classificador não tem regra para mensagens curtas sobre tempo sem verbo explícito.

### Fix — No classificador:
```
REGRA DE AGENDA POR PERÍODO:
Mensagens que mencionam PERÍODO DE TEMPO sem contexto financeiro explícito
devem ir para buscar_evento_agenda:
- "semana que vem", "próxima semana", "essa semana"
- "amanhã", "depois de amanhã", "próximos X dias"
- "mês que vem", "esse mês" (sem "gastos"/"gastei"/"financeiro")

Só vai para gerar_relatorio se tiver CONTEXTO FINANCEIRO explícito:
- "relatório da semana", "resumo de gastos", "quanto gastei na semana"
```

---

## BUG #5: Consultar lembretes mostra só dia atual — 2/5

### Evidências:
```
P1.24: "quais lembretes eu tenho?" → Só dia atual ⚠️
P2.24: "lista meus lembretes" → Só dia atual ⚠️
P5.24: "quais são meus lembretes?" → Só dia atual ⚠️
P3.24: "mostra meus próximos lembretes" → 2 semanas ✅
P4.24: "meus lembretes da semana" → Semana ✅
```

### Diagnóstico:

**Node:** AI Agent → tool `buscar_eventos`

Quando o user pede "quais lembretes eu tenho?", o AI Agent chama `buscar_eventos` com:
- `data_inicio_evento` = hoje
- `data_fim_evento` = hoje (ou hoje + poucas horas)

Quando o user diz "próximos lembretes" ou "lembretes da semana", o AI Agent expande o range.

### Causa raiz:
O AI Agent não tem instrução explícita de que "meus lembretes" = próximos 7-14 dias, não só hoje.

### Fix — No system prompt do AI Agent:
```
LEMBRETES:
Quando o usuário perguntar "quais lembretes tenho" ou "meus lembretes",
buscar dos próximos 14 dias, não só hoje.
"lembretes" sem especificação de data = próximos 14 dias.
```

---

## BUG #6: Contexto multi-turno registra gasto fantasma — 2/5

### Evidências:
```
P4.33: "e na anterior?" → REGISTROU R$1500 Freelance como novo gasto! ❌
P1.33: "e na semana passada?" → Tentou gerar relatório ⚠️
P5.33: "e no sábado?" → Perguntou se agenda ou gastos ⚠️
P2.33: "e amanhã?" → Sem eventos ✅
P3.33: "e depois de amanhã?" → Sem eventos ✅
```

### Diagnóstico:

**Node:** `registrar_gasto` prompt

O prompt tem a **REGRA DE CONTINUAÇÃO**:
```
Se a mensagem atual NÃO tem valor MAS é follow-up
("comece", "pode", "sim", "ok", "faça"...)
E o HISTÓRICO tem valores → extraia do histórico e registre.
```

"E na anterior?" não contém valor, mas o classificador pode ter interpretado como continuação. O histórico tinha "freelance R$1500" de uma busca anterior, e a IA extraiu e registrou como novo gasto.

### Causa raiz:
1. A REGRA DE CONTINUAÇÃO é muito agressiva
2. "E na [período]?" é ambíguo — pode ser busca ou continuação
3. O histórico Redis contém resultados de buscas anteriores que são interpretados como "valores para registrar"

### Fix — No prompt `registrar_gasto`:
```
REGRA DE CONTINUAÇÃO (RESTRITA):
Só ative continuação se a mensagem for EXATAMENTE uma dessas palavras isoladas:
"sim", "ok", "pode", "bora", "manda", "faça", "registre", "comece"

NÃO ative continuação para:
- Perguntas ("e na...", "e no...", "quanto...", "quais...")
- Referências a período ("semana passada", "mês anterior", "ontem")
- Emojis (👍, 😂, 🔥, etc)

Se for pergunta com "e" no início → branch = "buscar" (NÃO registrar)
```

---

## BUG #7: Confusão gasto vs evento na edição/exclusão — 2/10 (40%)

### Evidências:
```
P1.06: "muda o nome do almoço pra restaurante" → "Atualizei seu EVENTO" ❌ (era gasto!)
P4.08: "deleta parking" → "Não encontrei EVENTO" ❌ (era gasto!)
```

### Diagnóstico:

**Node:** `Escolher Branch` (classificador)

Quando a mensagem é "muda o nome do almoço pra restaurante", o classificador precisa decidir entre:
- `editar` (editar gasto)
- `editar_evento_agenda` (editar evento)

O classificador não tem contexto suficiente para saber se "almoço" é um gasto ou um evento. Depende do que foi feito antes na conversa.

### Causa raiz:
O classificador tem 12 branches e precisa decidir entre `editar` (financeiro) e `editar_evento_agenda` com base apenas no texto. Nomes como "almoço", "parking", "academia" podem ser tanto gasto quanto evento.

### Fix — No classificador:
```
REGRA DE EDIÇÃO/EXCLUSÃO:
Se o contexto recente contém um GASTO registrado com o mesmo nome:
→ usar editar/excluir (financeiro)
Se o contexto recente contém um EVENTO com o mesmo nome:
→ usar editar_evento_agenda/excluir_evento_agenda

Se ambíguo: usar o branch FINANCEIRO como padrão para edição/exclusão
(gastos são mais frequentes que eventos com nomes comuns)
```

---

## BUG #8: Excluir evento recorrente inconsistente — 3/5

### Evidências:
```
P1.19: "cancela academia de segunda" → "Não encontrei" ❌
P5.19: "tira futebol desse sábado" → "Não encontrei" ❌
P2.19: "cancela corrida de terça" → Excluiu ✅
P3.19: "tira musculação de quarta" → Excluiu ✅
P4.19: "exclui pilates de terça" → Excluiu ✅
```

### Diagnóstico:

**Node:** AI Agent → tool `excluir_evento` → webhook `/excluir-evento-total`

O problema está na **busca**. Quando o AI Agent chama `buscar_eventos` para encontrar a ocorrência específica:
- Busca por nome ("Academia") + data ("próxima segunda")
- Eventos recorrentes são expandidos em instâncias no banco
- Se a instância daquela data específica não existe como row separada, não encontra

Recorrentes no Supabase têm um registro base com `rrule`. As instâncias são calculadas, não rows fixas. A busca por `start_event` de uma data específica pode não achar se a instância não foi expandida.

### Causa raiz:
A busca de eventos não considera `rrule` — só busca por `start_event` exato. Instâncias de recorrentes podem não ter row no banco.

### Fix:
No webhook `busca-total-evento`, além de buscar por `start_event`, considerar eventos com `is_recurring = true` cujo `rrule` inclui o dia pedido. Ou expandir as instâncias antes de buscar.

---

## BUG #9: Excluir evento após rename falha — 3/5

### Evidências:
```
P4.18: "remove check-up" → "Não encontrei" ❌ (acabou de renomear para check-up)
P3.18: "cancela resolver pendências" → Pediu confirmação ⚠️
P1.18: "exclui consulta odonto" → Excluiu ✅
P2.18: "tira alinhamento semanal" → Excluiu ✅
P5.18: "apaga oftalmologista" → Excluiu ✅
```

### Diagnóstico:

**Workflow:** Calendar WebHooks → `editar-eventos` webhook

Quando o rename acontece, o workflow:
1. Busca evento pelo nome antigo
2. Atualiza no Supabase (`Update a row1`)
3. Se Google conectado: faz PATCH no Google Calendar

O problema: o PATCH no Google pode falhar silenciosamente, ou o UPDATE no Supabase pode não persistir corretamente se o node `Edit Fields5` monta os dados errados.

No P4: renomeou para "check-up" → IA disse sucesso → mas na busca seguinte "não encontrei". Pode ser que o Update atualizou no Supabase mas o Google Calendar manteve o nome antigo, e a consulta de agenda lê do Google.

### Causa raiz:
Inconsistência entre Supabase e Google Calendar após rename. A busca pode estar lendo de uma fonte enquanto o UPDATE foi na outra.

### Fix:
1. Verificar se o PATCH no Google Calendar está sendo chamado no rename
2. Garantir que a busca de eventos lê da mesma fonte que foi atualizada
3. Adicionar log para verificar se o UPDATE no Supabase realmente persistiu

---

## BUG #10: Cancelar lembrete recorrente "não encontrei" — 3/5

### Evidências:
```
P3.26: "tira o lembrete da internet" → "Não encontrei" ❌
P4.26: "tira o do condomínio" → "Não encontrei" ❌
P1.26: "cancela lembrete do aluguel" → Excluiu ✅
P2.26: "remove lembrete do relatório" → Excluiu ✅
P5.26: "cancela o do plano de saúde" → Excluiu ✅
```

### Diagnóstico:

Os que falharam têm em comum: mensagens mais curtas/vagas.
- "tira o lembrete da internet" → busca por "internet" não encontra "Pagar Internet"
- "tira o do condomínio" → busca por "condomínio" não encontra "Pagar condomínio"

Os que funcionaram:
- "cancela lembrete do aluguel" → busca por "aluguel" encontra "Pagar Aluguel"
- "remove lembrete do relatório" → busca por "relatório" encontra "Fazer Relatório"

### Causa raiz:
A busca no webhook `busca-total-evento` provavelmente faz `ILIKE '%termo%'`. "internet" deveria encontrar "Pagar Internet", mas pode ter conflito com capitalização ou o campo `event_name` estar armazenado de forma diferente.

Possível: "tira o do condomínio" é muito vago — "o do" não ajuda o AI Agent a montar a busca. Pode estar buscando por "condomínio" e o nome real é "Pagar Condomínio" com acento ou variação.

### Fix:
1. No webhook de busca, usar `ILIKE '%termo%'` case insensitive
2. No prompt de exclusão, instruir a IA a buscar pelo nome mais provável (sem artigos)

---

## BUG #11: TIMEOUT esporádico 67s — ocorre ~5% das vezes

### Evidências:
```
P1.22: "me lembra de comprar pão" → TIMEOUT 67s
P4.01: rodada anterior teve TIMEOUT 68s no mesmo tipo de mensagem
```

### Diagnóstico:

**Node:** AI Agent (tem `retryOnFail: true, maxTries: 5`)

Quando o OpenAI retorna erro ou timeout:
1. Primeira tentativa: ~10s
2. Wait: 300ms
3. Retry 2: ~10s
4. Wait: 300ms
5. ... até 5 tentativas

5 tentativas x ~13s = ~65s antes de falhar definitivamente.

### Causa raiz:
`maxTries: 5` com `waitBetweenTries: 300` pode acumular ~65s. Se o OpenAI está lento, 5 retries amplifica o problema.

### Fix:
Reduzir `maxTries` de 5 para 2 no node AI Agent:
```json
"retryOnFail": true,
"waitBetweenTries": 300,
"maxTries": 2
```
Resultado: timeout máximo cai de ~65s para ~26s.

---

## BUG #12: Edição de gasto cria novo ao invés de editar — 1/5

### Evidência:
```
P5.05: "a janta saiu 110, arruma pra mim" → ✅ Gasto registrado! R$110 (CRIOU NOVO!)
```

### Diagnóstico:

O classificador classificou "a janta saiu 110, arruma pra mim" como `criar_gasto` ao invés de `editar`. A frase "arruma pra mim" deveria indicar edição, mas "saiu 110" pareceu mais forte.

### Causa raiz:
O classificador não tem regra para "arruma", "corrige", "ajusta" → `editar`.

### Fix — No classificador:
```
REGRA DE EDIÇÃO FINANCEIRA:
Se a mensagem contém verbos de CORREÇÃO:
"corrige", "arruma", "ajusta", "era X não Y", "na verdade foi",
"o valor correto é", "errei o valor"
→ branch = "editar"
```

---

## RESUMO — CHECKLIST DE CORREÇÕES

| # | Bug | Onde corrigir | Node específico | Complexidade |
|---|-----|--------------|-----------------|-------------|
| 1 | Ação vs declaração | Classificador + AI Agent prompt | `Escolher Branch` + `AI Agent` | 10 min |
| 2 | Investimento como gasto | Classificador | `Escolher Branch` | 5 min |
| 3 | "Registro registrado" | Prompt financeiro | `registrar_gasto` | 5 min |
| 4 | "Semana que vem" = relatório | Classificador | `Escolher Branch` | 5 min |
| 5 | Lembretes só dia atual | AI Agent prompt | `AI Agent` system prompt | 2 min |
| 6 | Multi-turno gasto fantasma | Prompt financeiro | `registrar_gasto` (REGRA CONTINUAÇÃO) | 5 min |
| 7 | Confusão gasto vs evento | Classificador | `Escolher Branch` | 5 min |
| 8 | Excluir recorrente falha | Webhook busca | `busca-total-evento` | 15 min |
| 9 | Excluir após rename falha | Webhook edição | `editar-eventos` | 15 min |
| 10 | Cancelar lembrete recorrente | Webhook busca | `busca-total-evento` | 10 min |
| 11 | TIMEOUT 67s | AI Agent config | `AI Agent` maxTries | 1 min |
| 12 | Edição cria novo gasto | Classificador | `Escolher Branch` | 5 min |

### Tempo total estimado: ~1h15

### Prioridade de implementação:
```
1. Bugs 1+2 (classificador: ação vs declaração + investimento) — 15 min, resolve 40% dos erros
2. Bug 3 (Registro registrado) — 5 min, resolve 100% das receitas
3. Bug 6 (REGRA CONTINUAÇÃO) — 5 min, previne gastos fantasma
4. Bug 11 (maxTries) — 1 min, reduz timeouts
5. Bug 4 (semana que vem) — 5 min, resolve classificação
6. Bug 5 (lembretes) — 2 min, melhora UX
7. Bugs 7+12 (classificador edição) — 10 min
8. Bugs 8+9+10 (webhooks busca) — 30 min
```
