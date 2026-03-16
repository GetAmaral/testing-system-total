# Bugs e Fixes — Rodadas Mistas (48 testes de uso real)
**Data:** 2026-03-16
**Baseado em:** 6 rodadas x 8 cenários com linguagem variada

---

## BUG 1: "Como tão minhas finanças?" retorna tela de onboarding

### Evidência:
```
Input:  "como tão minhas finanças?"
Output: "F de verificação em seu email, envie-o aqui para a confirmação da sua conta.
         Caso o email não esteja correto, digite 'corrigir'"
```

### O que aconteceu:
A mensagem foi classificada incorretamente e caiu no fluxo de onboarding ao invés do fluxo financeiro.

### Causa provável:
No Main workflow, o node `Edit Fields` extrai `messageSet`:
```javascript
messageSet = $json.messages[0].interactive?.button_reply?.title
          || $json.messages[0].button?.text
          || $json.messages[0].text?.body
```

Se por algum motivo `messageSet` veio vazio ou foi classificado como stg 2/3 no Switch de onboarding, a mensagem caiu no fluxo errado.

O Switch no Main verifica `phones_whatsapp.stg`:
- stg 1 → pede email
- stg 2 → confirma email
- stg 3 → sim/não
- stg 4 → encaminha pro Premium/Standard

Se o user ficou com `stg` travado em 2 ou 3 na tabela `phones_whatsapp`, qualquer mensagem dele vai cair no onboarding ao invés do fluxo normal.

### Fix:
1. Verificar na tabela `phones_whatsapp` qual o `stg` do telefone `554391936205`
2. Se não for 4 (ou o valor final), corrigir para o valor correto
3. Considerar adicionar um timeout: se stg ficou em 1/2/3 por mais de 24h sem interação, resetar para 4

### No Supabase:
```sql
-- Verificar
SELECT * FROM phones_whatsapp WHERE phone = '554391936205';

-- Corrigir se necessário
UPDATE phones_whatsapp SET stg = 4 WHERE phone = '554391936205';
```

---

## BUG 2: IA registra AÇÕES como GASTOS (mais grave)

### Evidências:
```
"coloca 500 na poupança"     → ✅ Gasto registrado! R$500 Outros
"paga meu boleto de 300"     → ✅ Gasto registrado! R$300 Outros
"faz pix de 50 pro João"     → ✅ Gasto registrado! R$50 Outros
"transfere 100 pro João"     → ✅ Gasto registrado! R$100 Outros (teste anterior)
```

### O problema:
A IA não distingue entre:

| Tipo | Exemplo | Ação correta |
|------|---------|-------------|
| **Declaração** (passado) | "gastei 50 no uber" | ✅ Registrar como gasto |
| **Declaração** (passado) | "paguei 200 de luz" | ✅ Registrar como gasto |
| **Pedido de ação** (futuro) | "paga meu boleto de 300" | ❌ Recusar — IA não paga boletos |
| **Pedido de ação** (futuro) | "faz pix de 50 pro João" | ❌ Recusar — IA não faz pix |
| **Investimento** | "coloca 500 na poupança" | ❌ Recusar ou perguntar se quer registrar como saída |

### Impacto:
- Gastos fantasma são criados (R$300 de boleto que a IA "pagou")
- User pode achar que o boleto foi pago de verdade
- Extrato fica incorreto com gastos que não aconteceram

### Fix — Adicionar ao system prompt do AI Agent:

Na seção **REGRAS TÉCNICAS**, adicionar:

```
REGRA CRÍTICA — DECLARAÇÃO vs AÇÃO:
Só registre gastos/receitas quando o usuário DECLARAR algo que JÁ ACONTECEU.

DECLARAÇÕES (REGISTRAR):
- "gastei", "paguei", "comprei", "recebi", "ganhei", "torrei", "desembolsei"
- "foram X reais de...", "saiu X de...", "deu X no total"
- Qualquer frase no passado que indica algo já ocorrido

AÇÕES (NÃO REGISTRAR):
- "paga", "transfere", "faz pix", "deposita", "coloca na poupança"
- "manda pra", "envia pra", "passa pra", "investe em"
- Qualquer frase que PEDE para você EXECUTAR uma ação financeira

Quando o usuário pedir uma AÇÃO:
- NÃO registre como gasto
- Responda: "Não consigo executar transações financeiras, mas posso registrar esse valor como gasto se você já fez o pagamento. Quer que eu registre?"
- Só registre se o usuário confirmar

EXCEÇÃO: "paguei" é DECLARAÇÃO (passado), "paga" é AÇÃO (imperativo).
- "paguei 200 de luz" → registrar ✅
- "paga meu boleto de 200" → NÃO registrar, perguntar ❌
```

### Exemplos de como deveria responder:

```
User: "paga meu boleto de 300 reais"
IA: "Não consigo pagar boletos, mas posso registrar esse gasto se você já pagou. Quer que eu registre R$300 de boleto?"

User: "faz pix de 50 pro João"
IA: "Não consigo fazer transferências. Se você já fez o pix, quer que eu registre R$50 como gasto?"

User: "coloca 500 na poupança"
IA: "Não consigo movimentar contas, mas posso registrar R$500 como saída se você já transferiu. Quer que eu registre?"
```

---

## BUG 3: TIMEOUT esporádico de 68 segundos

### Evidência:
```
R4.01: "gasto 200 farmácia" → 68.3s → TIMEOUT
```

### Contexto:
Acontece esporadicamente. Na rodada 1, o mesmo tipo de gasto registrou em 9.5s. Na rodada 4, deu timeout.

### Causas prováveis:
1. **Redis tentando reconectar** — se o Redis Cloud volta e cai intermitentemente, o node fica esperando
2. **n8n sobrecarregado** — muitas execuções simultâneas (schedule trigger + múltiplos testes)
3. **Supabase lento** — pico de latência no banco

### Fix:
1. Resolver o Redis (instalar local ou reconectar cloud)
2. Adicionar timeout de 30s no AI Agent (já tem `retryOnFail: true, maxTries: 5` — o retry pode estar multiplicando a latência)
3. Reduzir `maxTries` de 5 para 2 no AI Agent

---

## BUG 4: Busca por nome composto falha

### Evidência:
```
R6.05: "gasto 80 mensalidade academia" → ✅ Registrou "Mensalidade Academia"
R6.06: "na verdade era 90, não 80"     → "Não encontrei registro"
R6.07: "apaga gasto da academia"       → "Não encontrei registro"
```

### O problema:
O registro foi criado como "Mensalidade Academia" mas a busca por "academia" não encontra. A tool `buscar_financeiro` provavelmente faz match exato ou não consegue buscar por parte do nome.

### Fix:
No webhook `/filtros-supabase` (busca financeira), mudar a query de:
```sql
WHERE name_spent = 'academia'       -- match exato
```
Para:
```sql
WHERE name_spent ILIKE '%academia%' -- match parcial, case insensitive
```

Ou: instruir a IA no prompt a buscar pelo nome completo:
```
Ao buscar registros para editar/excluir, use o NOME COMPLETO do registro.
Se o usuário disse "apaga o gasto da academia", busque por "academia" E por "mensalidade academia".
Se não encontrar na primeira busca, tente variações.
```

---

## BUG 5: Exclusão de evento mistura resposta com extrato

### Evidência:
```
R2.07: "desmarca a call de sexta"
Output: "✅ Evento da call na sexta-feira foi removido.
         ✅ Busca completa! Totais: Saldo R$3.628..."
         (52 registros financeiros despejados)
```

### O problema:
O AI Agent chamou 2 tools: `excluir_evento` + `buscar_financeiro`. Misturou a resposta de exclusão com um extrato financeiro completo que ninguém pediu.

### Fix:
No system prompt do AI Agent, adicionar:
```
• Quando excluir um evento ou gasto, responda APENAS sobre a exclusão.
  NÃO chame outras tools na mesma resposta.
  NÃO inclua extrato financeiro ao excluir evento.
  NÃO inclua agenda ao excluir gasto.
  Uma ação por resposta.
```

---

## BUG 6: Edição de recorrente edita só uma ocorrência

### Evidência:
```
R6.03: "muda a natação pras 18h"
Output: "Atualizei: Natação 16/03 às 18h" (só uma ocorrência, não a regra)
```

### O problema:
O workflow de edição encontra a primeira ocorrência e edita só ela. Não altera a regra de recorrência (`rrule`).

### Fix:
No prompt de edição de eventos (`prompt_editar1`), adicionar:
```
Para eventos RECORRENTES, ao editar horário:
- Se o usuário quer mudar TODAS as ocorrências: editar o campo rrule/horário base
- Se quer mudar UMA ocorrência específica: criar exceção (exdate) + evento avulso
- SEMPRE perguntar: "Quer alterar todas as ocorrências ou só esta?"
```

---

## BUG 7: "Registro registrado" persiste

### Evidência:
```
R3.04: "recebi 1500 de freelance" → "✅ Registro registrado!"
```

### Fix:
No prompt financeiro (`registrar_gasto`), trocar a mensagem de resposta:

De:
```
"✅ Registro registrado!"
```
Para:
```
Se entra_sai_gasto === "entrada":
  "✅ Entrada registrada!"
Se entra_sai_gasto === "saida":
  "✅ Gasto registrado!"
```

E categorizar receitas como "Renda" ao invés de "Outros":
```
- Salário, freelance, comissão → Categoria: "Renda"
- Venda, revenda → Categoria: "Vendas"
- Outros → Categoria: "Outros"
```

---

## BUG 8: Evento movido não aparece na consulta

### Evidência:
```
R4.05: "muda dentista pra sábado mesmo horário" → ✅ Atualizou 21/03 10:00
R4.08: "o que tenho sexta e sábado?" → Mostrou call sexta, SEM dentista sábado
```

### Causa provável:
O rename/edição de evento pode estar atualizando no Supabase mas não no Google Calendar, ou vice-versa. A consulta de agenda lê de uma fonte diferente da que foi atualizada.

### Fix:
Verificar no workflow `editar-eventos` se o PATCH no Google Calendar está sendo feito quando o evento é movido de data. O node `editar_evento_google3` pode não estar sendo acionado quando só a data muda.

---

## BUG 9: Relatório como fallback genérico

### Evidências:
```
R5.01: "faz um orçamento mensal" → "Relatório sendo gerado 🔃"
R5.05: "cria planilha com meus gastos" → "Relatório sendo gerado 🔃"
```

### O problema:
A IA interpreta pedidos fora do escopo como pedidos de relatório e chama a tool `gerar_relatorio`. O user espera um orçamento/planilha e recebe um relatório diferente.

### Fix:
No system prompt, reforçar:
```
• "Orçamento mensal" NÃO é relatório. Responda: "Não crio orçamentos, mas posso gerar seu relatório de gastos do mês. Quer?"
• "Planilha" NÃO é relatório. Responda: "Não exporto planilhas. No site totalassistente.com.br você pode visualizar seus gastos organizados."
• Só chame gerar_relatorio quando o usuário pedir EXPLICITAMENTE "relatório", "resumo de gastos" ou "como foram meus gastos em [período]"
```

---

## RESUMO: TODAS AS CORREÇÕES DE PROMPT

Juntando todos os fixes de prompt em um bloco:

```
=== ADICIONAR AO SYSTEM PROMPT DO AI AGENT ===

Na seção "O QUE VOCÊ NÃO FAZ":
• NÃO define limites de gasto por categoria
• NÃO executa transações financeiras (pix, boleto, transferência, depósito)
• NÃO cria orçamentos, planilhas ou exportações

Na seção "REGRAS TÉCNICAS":

DECLARAÇÃO vs AÇÃO:
Só registre gastos quando o usuário DECLARAR algo que JÁ ACONTECEU.
Palavras de DECLARAÇÃO (registrar): "gastei", "paguei", "comprei", "recebi", "ganhei"
Palavras de AÇÃO (NÃO registrar): "paga", "transfere", "faz pix", "deposita", "coloca na"
Se for AÇÃO: "Não consigo executar transações, mas posso registrar se você já fez. Quer?"

RECEITAS:
Ao registrar entrada/receita, diga "✅ Entrada registrada!" (não "Registro registrado")
Categorize: salário/freelance → "Renda", vendas → "Vendas"

EXCLUSÃO:
Quando excluir evento ou gasto, responda APENAS sobre a exclusão.
NÃO chame outras tools na mesma resposta.

RELATÓRIO:
Só chame gerar_relatorio quando pedido EXPLICITAMENTE.
"Orçamento" e "planilha" NÃO são relatório — recuse com clareza.

RECORRENTES:
Ao editar horário de recorrente, perguntar: "Quer alterar todas ou só esta?"
```

---

## CHECKLIST DE IMPLEMENTAÇÃO

| # | Fix | Onde | Complexidade |
|---|-----|------|-------------|
| 1 | Verificar stg do user em phones_whatsapp | Supabase | 1 min |
| 2 | Regra declaração vs ação no prompt | AI Agent system prompt | 5 min |
| 3 | Trocar "Registro registrado" → "Entrada registrada" | Prompt financeiro | 1 min |
| 4 | Categorizar freelance como "Renda" | Prompt financeiro | 1 min |
| 5 | Busca parcial (ILIKE) no filtros-supabase | Webhook financeiro | 5 min |
| 6 | Não misturar tools na exclusão | AI Agent system prompt | 1 min |
| 7 | Perguntar "todas ou só esta?" em recorrentes | Prompt edição eventos | 1 min |
| 8 | Relatório só quando explícito | AI Agent system prompt | 1 min |
| 9 | Reduzir maxTries de 5 para 2 no AI Agent | Node AI Agent | 1 min |
| 10 | Verificar PATCH Google Calendar na edição de data | Workflow editar-eventos | 10 min |
