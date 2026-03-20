# Auditoria 360 — Broad Level Results

**Data:** 2026-03-20T13:23 UTC
**Agente:** Lupa (@auditor)
**Nivel:** Broad (acumulativo com Quick)

---

## Resultados Broad — Financeiro

| ID | Input | IA | Banco | Veredicto |
|----|-------|----|-------|-----------|
| FIN-B1 | torrei 60 conto no boteco ontem | Gasto registrado! Boteco R$60 Lazer | IA disse criou, count nao subiu imediatamente | FAIL (timing da contagem) |
| FIN-B2 | caiu 3000 na conta do trabalho | Entrada registrada | Trabalho R$3000 Outros entrada type:fixo | PASS |
| FIN-B3 | muda boteco pra bar do ze | Edicao concluida | Bar Do Ze encontrado apos 20s | PASS |
| FIN-B4 | coloca bar do ze na categoria lazer | Edicao concluida | Async - verificacao inconclusiva | FAIL ou ASYNC |
| FIN-B5 | gastos de transporte | Busca completa | Cruzamento por resposta | PASS |
| FIN-B6 | apaga meu ultimo gasto | Exclusao concluida | spent: 84 para 83 | PASS |
| FIN-B8 | paga meu boleto de 200 | Nao consigo executar transacoes | nada criado | PASS |
| FIN-B9 | aplica 2000 em CDB | Nao consigo executar investimentos | nada criado | PASS |
| FIN-B10 | gastei 29.90 de gasolina | Gasto registrado! R$29.90 | Gasolina R$29.9 Transporte saida type:variavel | PASS |

## Resultados Broad — Agenda

| ID | Input | IA | Banco | Veredicto |
|----|-------|----|-------|-----------|
| AGD-B1 | consulta no dermato segunda 10h30 | Evento agendado! 23/03 10h30 | Consulta No Dermato 2026-03-23T10:30 compromisso | PASS |
| AGD-B3 | call com equipe hoje 16h | Evento agendado! | Call Com Equipe 2026-03-20T16:00 compromisso | PASS |
| REC-Q1 | natacao toda terca e quinta 17h | Evento recorrente registrado | rec:True rrule:FREQ=WEEKLY;BYDAY=TU,TH | PASS |
| REC-Q2 | todo dia 10 me lembra de pagar internet | Evento recorrente registrado | rec:True rrule:FREQ=MONTHLY;BYMONTHDAY=10 | PASS |
| CON-B4 | o que tenho dia 25? | Agenda do dia 25 | nada criado (correto) | PASS |
| CON-B5 | o que tenho dia 30 de abril? | Resposta de agenda | nada criado | PASS |
| MOD-B3 | muda a festa de aniversario pro dia 28 | (resposta nao capturada) | Evento nao existe - IA deveria recusar | FAIL (IA nao informou claramente) |
| DEL-B3 | cancela consulta no dermato | Exclusao | cal: 314 para 313, dermato: NOT_FOUND | PASS |

## Resultados Broad — Bot WhatsApp

| ID | Input | IA | Banco | Veredicto |
|----|-------|----|-------|-----------|
| PREM-B2 | me conta uma piada | Recusa educada | nada criado | PASS |
| PREM-B7 | (emoji) | Resposta generica | nada criado | PASS |

---

## Resumo Consolidado (Quick + Broad)

| Nivel | Total | PASS | PARTIAL | FAIL |
|-------|-------|------|---------|------|
| Quick | 17 | 12 | 3 | 2 |
| Broad | 19 | 15 | 0 | 4 |
| **TOTAL** | **36** | **27 (75%)** | **3 (8%)** | **6 (17%)** |

---

## Analise dos FAILs Broad

### FIN-B1: Gasto criado mas count nao subiu
- **Camada:** Possivel timing — contagem feita antes do INSERT completar
- **Nota:** IA disse que criou e o registro foi encontrado depois. Provavelmente PASS com timing melhor.

### FIN-B4: Edicao de categoria async
- **Camada:** ASYNC_INCOMPLETO
- **Nota:** Mesmo padrao dos testes anteriores. Edicao de categoria pode demorar mais que 20s.

### MOD-B3: Editar evento inexistente
- **Camada:** AI AGENT (camada 2)
- **Nota:** IA deveria dizer claramente "nao encontrei" mas resposta nao foi capturada limpa. Precisa re-testar.

### FIN-B1 reclassificado: PASS_DELAYED
- O registro "Boteco R$60" FOI encontrado no banco (DB: Boteco na query posterior em FIN-B3).
- O count nao subiu porque a query de contagem rodou antes do INSERT completar.
- **Reclassificado: PASS_DELAYED**

---

## Destaques positivos

- **Recorrentes funcionam:** FREQ=WEEKLY;BYDAY=TU,TH e FREQ=MONTHLY;BYMONTHDAY=10 gravados corretamente
- **Centavos:** R$29.90 gravado como 29.9 (correto)
- **Acao vs declaracao:** "paga boleto" e "aplica em CDB" recusados corretamente
- **Exclusao com nome unico:** dermato excluido com sucesso
- **Emoji:** Nao quebra o sistema

## Divergencias recorrentes

- **FIN-B2:** type_spent="fixo" para "caiu 3000 do trabalho" — deveria ser "variavel" ou "eventuais"?
- **Categoria Outros:** Receitas continuam indo pra "Outros" em vez de "Renda"/"Renda Extra"

---

*Relatorio gerado por @auditor (Lupa) — DEV-ONLY*
