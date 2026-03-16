# Testes Mistos — 6 Rodadas x 8 Cenários (48 testes)
**Data:** 2026-03-16
**Metodologia:** Simular uso real — ações variadas por rodada, linguagem diferente a cada vez

---

## RODADA 1 — Uso natural misturado

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R1.01 | "oi, bom dia" | 5.5s | Saudação amigável | ✅ |
| R1.02 | "gastei 35 no almoço" | 9.5s | R$35 Alimentação | ✅ |
| R1.03 | "tenho médico quinta às 15h" | 5.1s | Consulta Médica 19/03 15:00 | ✅ |
| R1.04 | "me avisa amanhã cedo pra tomar remédio" | 10.0s | Lembrete amanhã 9h | ✅ |
| R1.05 | "quanto já gastei essa semana?" | 14.0s | Extrato com totais | ✅ |
| R1.06 | "cancela o médico de quinta" | 15.9s | Excluiu Consulta Médica | ✅ |
| R1.07 | "na verdade o almoço foi 42, corrige aí" | 16.5s | Valor atualizado R$42 | ✅ |
| R1.08 | "o que tenho pra essa semana?" | 7.2s | Agenda da semana | ✅ |

**Rodada 1: 8/8 ✅ — Perfeito!**

---

## RODADA 2 — Variações de linguagem (gírias, informal)

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R2.01 | "eae" | 4.9s | Saudação casual | ✅ |
| R2.02 | "mete 120 de supermercado aí" | 4.9s | R$120 Alimentação | ✅ |
| R2.03 | "bota uma call com o time sexta 16h" | 7.0s | Call com Time 20/03 16:00 | ✅ |
| R2.04 | "tira o gasto do supermercado que lancei agora" | 13.9s | Excluiu R$120 | ✅ |
| R2.05 | "agenda yoga toda terça e quinta 6h" | 5.2s | Recorrente criado | ✅ |
| R2.06 | "como tão minhas finanças?" | 5.0s | **Resposta de verificação de email/conta** | ❌ BUG |
| R2.07 | "desmarca a call de sexta" | 18.1s | Excluiu call MAS despejou extrato financeiro junto | ⚠️ |
| R2.08 | "me manda resumo dos gastos do mês" | 7.0s | "Relatório sendo gerado 🔃" | ✅ |

**Rodada 2: 6/8 ✅, 1 ⚠️, 1 ❌**
- R2.06: **BUG CRÍTICO** — "como tão minhas finanças?" retornou mensagem de verificação de email ("F de verificação em seu email"). Parece conflito com fluxo de onboarding.
- R2.07: Excluiu a call mas misturou resposta com extrato financeiro completo (52 registros!)

---

## RODADA 3 — Cenários complexos

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R3.01 | "hoje gastei 15 café, 45 almoço e 30 uber" | 9.6s | 3 lançamentos de uma vez | ✅ |
| R3.02 | "lembrete pagar cartão todo dia 10" | 11.5s | Recorrente dia 10 às 9h | ✅ |
| R3.03 | "muda yoga de terça e quinta pras 7h" | 13.8s | Atualizou 17/03 e 19/03 | ✅ |
| R3.04 | "recebi 1500 de freelance" | 7.1s | "Registro registrado!" Cat: Outros | ⚠️ |
| R3.05 | "apaga todos os gastos de uber" | 20.4s | Excluiu 3 ubers de uma vez | ✅ |
| R3.06 | "tenho algo marcado pra semana que vem?" | 7.1s | Yoga terça e quinta | ✅ |
| R3.07 | "reunião com investidor dia 28 às 9h e às 14h" | 7.1s | 2 eventos criados | ✅ |
| R3.08 | "exclui o lembrete do cartão" | 13.7s | Excluiu Pagar Cartão | ✅ |

**Rodada 3: 7/8 ✅, 1 ⚠️**
- R3.04: "Registro registrado" (redundante) e categoria "Outros" para freelance

---

## RODADA 4 — Edição e exclusão variada

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R4.01 | "gasto 200 farmácia" | **68.3s** | TIMEOUT | ❌ |
| R4.02 | "dentista sexta às 10h" | 8.1s | Consulta Dentista 20/03 | ✅ |
| R4.03 | "gasto 60 gasolina" | 8.1s | R$60 Transporte | ✅ |
| R4.04 | "corrige a farmácia pra 250" | 15.1s | Corrigiu Drogaria (nome antigo) R$250 | ⚠️ |
| R4.05 | "muda dentista pra sábado mesmo horário" | 12.3s | Atualizou 21/03 10:00 | ✅ |
| R4.06 | "apaga a gasolina" | 27.2s | Excluiu R$60 | ✅ |
| R4.07 | "quanto gastei hoje?" | 11.5s | Extrato correto | ✅ |
| R4.08 | "o que tenho sexta e sábado?" | 9.3s | Mostrou Call sexta, sem dentista sábado | ⚠️ |

**Rodada 4: 5/8 ✅, 2 ⚠️, 1 ❌**
- R4.01: TIMEOUT de 68s — mesmo problema esporádico de antes
- R4.04: Corrigiu mas usou nome "Drogaria" (de um teste anterior) ao invés de "Farmácia"
- R4.08: Não mostrou o dentista que foi movido pro sábado

---

## RODADA 5 — Alucinação e escopo

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R5.01 | "faz um orçamento mensal" | 4.9s | Gerou relatório (fallback) | ⚠️ |
| R5.02 | "coloca 500 na poupança" | 5.9s | **Registrou como GASTO R$500** | ❌ |
| R5.03 | "manda email pro chefe" | 7.2s | Recusou, ofereceu lembrete | ✅ |
| R5.04 | "previsão do tempo amanhã?" | 5.9s | Recusou corretamente | ✅ |
| R5.05 | "cria planilha com meus gastos" | 7.0s | Gerou relatório (fallback) | ⚠️ |
| R5.06 | "me empresta 100 reais" | 7.6s | Recusou com humor | ✅ |
| R5.07 | "paga meu boleto de 300" | 4.9s | **Registrou como GASTO R$300** | ❌ |
| R5.08 | "faz pix de 50 pro João" | 7.1s | **Registrou como GASTO R$50** | ❌ |

**Rodada 5: 3/8 ✅, 2 ⚠️, 3 ❌**
- R5.02: "coloca na poupança" → registrou como gasto (deveria recusar ou perguntar)
- R5.07: "paga meu boleto" → registrou como gasto (IA não paga boletos!)
- R5.08: "faz pix" → registrou como gasto (repetição do bug 8.8)

**Padrão: a IA interpreta qualquer menção a dinheiro como gasto, mesmo quando o user está pedindo uma AÇÃO (pagar, transferir, depositar)**

---

## RODADA 6 — Recorrentes e verificação

| # | Input | Latência | Resultado | Status |
|---|-------|----------|-----------|--------|
| R6.01 | "natação toda segunda e quarta 17h" | 4.9s | Recorrente criado | ✅ |
| R6.02 | "o que tenho de recorrente?" | 9.5s | Listou Natação + Yoga 2 semanas | ✅ |
| R6.03 | "muda natação pras 18h" | 11.7s | Atualizou 16/03 18h (só uma) | ⚠️ |
| R6.04 | "cancela natação de segunda" | 16.2s | Excluiu 16/03 18:00 | ✅ |
| R6.05 | "gasto 80 mensalidade academia" | 7.2s | R$80 Saúde/Fixo | ✅ |
| R6.06 | "na verdade era 90, não 80" | 9.3s | "Não encontrei registro" | ❌ |
| R6.07 | "apaga gasto da academia" | 9.4s | "Não encontrei registro" | ❌ |
| R6.08 | "quanto gastei hoje no total?" | 11.5s | Extrato completo | ✅ |

**Rodada 6: 4/8 ✅, 1 ⚠️, 2 ❌, 1 missing**
- R6.03: Editou só uma ocorrência, não a regra de recorrência
- R6.06: Não encontrou "mensalidade academia" para editar — pode ser problema de nome/busca
- R6.07: Não encontrou para excluir — mesmo problema

---

## RESUMO DAS 6 RODADAS

| Rodada | Foco | ✅ | ⚠️ | ❌ |
|--------|------|-----|------|-----|
| 1 | Uso natural | 8 | 0 | 0 |
| 2 | Linguagem informal | 6 | 1 | 1 |
| 3 | Cenários complexos | 7 | 1 | 0 |
| 4 | Edição e exclusão | 5 | 2 | 1 |
| 5 | Alucinação e escopo | 3 | 2 | 3 |
| 6 | Recorrentes + verificação | 4 | 1 | 2 |
| **TOTAL** | **48 cenários** | **33 (69%)** | **7 (14%)** | **7 (15%)** |

### Progressão: 55% → 65% → 69% de sucesso

---

## BUGS ENCONTRADOS

### CRÍTICOS:

1. **R2.06** — "como tão minhas finanças?" retornou mensagem de ONBOARDING ("F de verificação em seu email"). Conflito entre classificação de mensagem e fluxo de onboarding.

2. **R5.02/R5.07/R5.08** — IA registra como gasto quando user pede ações financeiras (pagar boleto, fazer pix, colocar na poupança). A IA deveria recusar ações e só registrar declarações de gasto passado.

3. **R4.01** — TIMEOUT de 68s ao registrar gasto (esporádico mas grave).

### MÉDIOS:

4. **R6.06/R6.07** — Não encontra registro para editar/excluir quando o nome é "Mensalidade Academia". Possível problema de busca por nome composto.

5. **R2.07** — Ao excluir evento, despejou extrato financeiro completo junto com a confirmação.

6. **R6.03** — Edição de recorrente edita UMA ocorrência, não a regra.

### PERSISTENTES:

7. **"Registro registrado"** (R3.04) — ainda não corrigido
8. **Categoria "Outros" para freelance** — deveria ser "Renda"
9. **Relatório como fallback** para pedidos fora do escopo (R5.01, R5.05)

---

## PADRÃO DESCOBERTO: IA registra ações como gastos

A IA não distingue entre:
- **Declaração** (passado): "gastei 50 no uber" → ✅ deve registrar
- **Pedido de ação** (futuro): "paga meu boleto de 300" → ❌ não deve registrar
- **Transferência**: "faz pix de 50" → ❌ não deve registrar
- **Investimento**: "coloca 500 na poupança" → ❌ não deve registrar

**Sugestão para o prompt:**
```
REGRA CRÍTICA: Só registre gastos quando o usuário DECLARAR algo que JÁ ACONTECEU.
Se o usuário PEDIR UMA AÇÃO (pagar, transferir, fazer pix, depositar, colocar na poupança),
NÃO registre — diga que não pode executar ações financeiras, apenas registrar.
Palavras de AÇÃO (não registrar): "paga", "transfere", "faz pix", "deposita", "coloca na", "manda pra"
Palavras de DECLARAÇÃO (registrar): "gastei", "paguei", "comprei", "recebi", "ganhei"
```
