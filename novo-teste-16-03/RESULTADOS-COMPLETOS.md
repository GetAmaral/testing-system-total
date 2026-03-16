# Bateria Completa de Testes — 16/03/2026
**Ambiente:** N8N Dev (http://76.13.172.17:5678)
**Usuário teste:** Luiz Felipe (554391936205)
**Total:** 13 módulos, 93 cenários
**Objetivo:** Verificar progresso após alterações estruturais do fim de semana

---

## MÓDULO 1: GESTÃO FINANCEIRA (8 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 1.1 | "gastei 50 reais no mercado" | 7.3s | R$50 Alimentação | ✅ | ✅ |
| 1.2 | "paguei 200 de luz" | 7.1s | R$200 Moradia | ✅ | ✅ |
| 1.3 | "recebi 3000 de salário" | 7.1s | "Registro registrado!" Cat: Outros | ⚠️ | ⚠️ |
| 1.4 | "quanto gastei esse mês?" | 11.5s | Extrato com conteúdo ofensivo de testes | ⚠️ | ⚠️ |
| 1.5 | "quero gastar no máximo 500 em alimentação" | 4.8s | "Vou estar aqui para ajudar a acompanhar" | ✅ MELHOROU | ⚠️ |
| 1.6 | "investi 1000 em tesouro direto" | 7.4s | Registrou como GASTO | ❌ | ❌ |
| 1.7 | "torrei 80 conto no ifood ontem" | 7.1s | R$80 Alimentação | ✅ | ✅ |
| 1.8 | "gastei dez conto no uber" | 7.1s | R$10 Transporte | ✅ | ✅ |

**Mudanças vs anterior:**
- 1.3: "Registro registrado" AINDA aparece (não foi corrigido no prompt)
- 1.5: MELHOROU — antes alucinava que ia salvar limite, agora diz "vou acompanhar" (mais honesto)
- 1.6: Investimento ainda vira gasto (sem mudança)

---

## MÓDULO 2: AGENDA/CALENDÁRIO (7 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 2.1 | "dentista amanhã às 14h" | 9.4s | Agendado 17/03 14:00 | ✅ | ✅ |
| 2.2 | "academia toda seg/qua/sex às 7h" | 7.1s | Recorrente registrado | ✅ | ✅ |
| 2.3 | "o que tenho pra hoje?" | 9.3s | Listou 16 eventos do dia | ✅ CORRIGIDO | ⚠️ |
| 2.4 | "preciso resolver negócio do banco" | 4.9s | Pediu dia e horário | ✅ | ✅ |
| 2.5 | "reunião amanhã às 14h" (conflito) | 7.0s | Agendou sem avisar conflito | ❌ | ❌ |
| 2.6 | "me lembra de pagar boleto dia 20" | 7.1s | Lembrete criado | ✅ | ✅ |
| 2.7 | "cancela reunião de amanhã" | 13.7s | Listou 3 reuniões e pediu qual | ✅ MELHOROU | ✅ |

**Mudanças vs anterior:**
- 2.3: CORRIGIDO — antes dizia "não encontrei eventos", agora lista corretamente
- 2.5: Conflito AINDA não detectado
- 2.7: MELHOROU — antes cancelava direto, agora lista opções quando tem mais de uma

---

## MÓDULO 3: GOOGLE CALENDAR SYNC (5 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 3.1 | "meu google calendar tá conectado?" | 4.9s | Sim, conectado | ✅ | ✅ |
| 3.2 | "agendar reunião dia 20 + sync google" | 4.9s | Agendado 20/03 15:00 | ✅ | ⚠️ |
| 3.3 | "desconectar google calendar" | 4.9s | Redirecionou pro site | ✅ | ✅ |
| 3.4 | "quais eventos essa semana?" | 15.9s | Listou semana 16-22/03 CORRETA | ✅ CORRIGIDO | ⚠️ |
| 3.5 | "conectar google calendar" | 4.8s | "Já está conectado" | ✅ | ✅ |

**Mudanças vs anterior:**
- 3.4: CORRIGIDO — antes retornava semana passada, agora retorna semana atual corretamente

---

## MÓDULO 4: PLANOS E PAGAMENTOS (5 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 4.1 | "qual meu plano?" | 4.9s | "Você não me passou informações sobre plano" | ❌ | ❌ |
| 4.2 | "relatório completo com gráficos" | 7.1s | "Relatório sendo gerado 🔃" | ⚠️ | ⚠️ |
| 4.3 | "quanto custa o premium?" | 4.9s | Redirecionou pro site | ✅ MELHOROU | ❌ |
| 4.4 | "cancelar assinatura" | 4.9s | Redirecionou ao canal oficial | ✅ MELHOROU | ❌ |
| 4.5 | "último pagamento aprovado?" | 9.3s | Mostrou extrato financeiro | ⚠️ | ⚠️ |

**Mudanças vs anterior:**
- 4.3: MELHOROU — antes dizia "não tenho informações", agora redireciona ao site
- 4.4: MELHOROU — antes dizia "não tenho acesso", agora guia ao canal oficial

---

## MÓDULO 5: ANTI-SPAM (3 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 5.1 | "oi" 5x seguidas | ~4.9s cada | Todas respondidas, variou texto | ⚠️ | ⚠️ |
| 5.3 | Spam 400+ chars | 4.9s | "Não identifiquei comando claro" | ✅ | ✅ |
| 5.4 | Link suspeito/golpe | 4.9s | "Não vou abrir links" | ✅ | ✅ |

---

## MÓDULO 6: CONVERSAÇÃO E UX (4 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 6.1 | "bom dia" | 4.9s | Saudação amigável com emoji | ✅ | ✅ |
| 6.2 | "capital da França?" | 4.9s | RESPONDEU "Paris" + redirecionou | ⚠️ REGREDIU | ✅ |
| 6.3 | "qunto gastei esi mes?" | 13.9s | Entendeu e mostrou extrato | ✅ | ✅ |
| 6.4 | "e no mês passado?" | 7.1s | Entendeu contexto, sem registros | ✅ | ✅ |

**Mudanças vs anterior:**
- 6.2: REGREDIU — antes recusava educadamente ("fora do que consigo fazer"), agora RESPONDEU a pergunta. Deveria manter escopo.

---

## MÓDULO 7: EDGE CASES (3 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 7.1 | " " (espaço) | 4.9s | "Mensagem veio vazia" | ✅ | ✅ |
| 7.2 | "👍" | 27.0s | **REGISTROU TODOS OS GASTOS DO HISTÓRICO** | ❌ NOVO BUG | ✅ |
| 7.3 | Mensagem longa múltiplos gastos | 9.3s | Calculou e ofereceu registrar | ✅ MELHOROU | ⚠️ |

**Mudanças vs anterior:**
- 7.2: **BUG CRÍTICO NOVO** — Emoji "👍" foi interpretado como confirmação e registrou 16 lançamentos duplicados do histórico!
- 7.3: MELHOROU — antes só oferecia ajuda futura, agora calculou R$4725 de gastos e R$1275 sobrando

---

## MÓDULO 8: ALUCINAÇÃO (12 cenários)

| # | Input | Resultado | Status | Antes |
|---|-------|-----------|--------|-------|
| 8.1 | Plano de investimentos | Recusou, ofereceu relatório | ✅ | ✅ |
| 8.2 | Plano de lucro mensal | Recusou, ofereceu relatório | ✅ | ✅ |
| 8.3 | Carteira de investimentos | Recusou, sugeriu app | ✅ | ✅ |
| 8.4 | Limite de 300 pra transporte | "Não tenho como definir limites" | ✅ CORRIGIDO | ❌ |
| 8.5 | Meta de 10 mil | Recusou, ofereceu relatório | ✅ | ✅ |
| 8.6 | Simular empréstimo | Recusou, ofereceu registrar parcelas | ✅ | ✅ |
| 8.7 | Dicas de economia | Gerou relatório como fallback | ⚠️ | ⚠️ |
| 8.8 | Transferir 100 pro João | **REGISTROU COMO GASTO** | ❌ | ✅ |
| 8.9 | Valor do dólar | Recusou corretamente | ✅ | ✅ |
| 8.10 | Ativar plano premium | Recusou corretamente | ✅ | ✅ |
| 8.11 | Exportar em PDF | Gerou relatório como fallback | ⚠️ | ⚠️ |
| 8.12 | Conectar Nubank | Recusou corretamente | ✅ | ✅ |

**Mudanças vs anterior:**
- 8.4: CORRIGIDO — antes alucinava que ia salvar limite, agora diz "não tenho como"
- 8.8: REGREDIU — antes recusava "não faço transferências", agora registrou R$100 "Transferência para João" como gasto

---

## MÓDULO 9: EDIÇÃO/EXCLUSÃO (12 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 9.0a | Criar gasto farmácia | 7.3s | R$150 Saúde | ✅ | ✅ |
| 9.0b | Criar evento reunião | 7.2s | 25/03 10h | ✅ | ✅ |
| 9.0c | Criar gasto gasolina | 5.0s | R$90 Transporte | ✅ | ✅ |
| 9.1 | Editar valor farmácia | 16.2s | R$180 atualizado | ✅ | ✅ |
| 9.2 | Editar categoria gasolina | **31.4s** | Categoria atualizada | ⚠️ | ⚠️ |
| 9.3 | Renomear farmácia → drogaria | 18.2s | Renomeou, manteve R$180 | ✅ | ⚠️ |
| 9.4 | Excluir gasolina | 20.4s | Excluído R$90 | ✅ | ✅ |
| 9.5 | Excluir último gasto | 9.3s | Excluiu "Transferência João" | ✅ | ⚠️ |
| 9.6 | Editar horário evento | **24.7s** | "Não encontrei" | ❌ | ❌ |
| 9.7 | Renomear evento | 9.2s | Renomeou mas "início: desconhecido" | ❌ | ❌ |
| 9.8 | Excluir evento renomeado | 18.1s | "Não encontrei" | ❌ | ❌ |
| 9.9 | Limpar eventos de amanhã | 24.8s | Listou 17 e pediu confirmação | ✅ MELHOROU | ⚠️ |

**Mudanças vs anterior:**
- 9.3: MELHOROU — manteve valor R$180 após rename (antes revertia)
- 9.9: MELHOROU — agora lista e pede confirmação ao invés de excluir direto
- 9.6/9.7/9.8: MESMO PROBLEMA — edição de evento continua quebrando

---

## MÓDULO 10: LEMBRETES (8 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 10.1 | Lembrete remédio 21h | 7.1s | Criado hoje 21h | ✅ | ✅ |
| 10.2 | Lembrete amanhã 8h banco | 4.9s | Criado amanhã 8h | ✅ | ✅ |
| 10.3 | Lembrete recorrente vitamina | 7.1s | Recorrente todo dia 7h | ✅ | ✅ |
| 10.4 | Lembrete dia 25 pagar cartão | 7.1s | Criado dia 25 | ✅ MELHOROU | ⚠️ |
| 10.5 | Quais lembretes tenho? | 31.4s | Listou 16-25/03 completo | ✅ MELHOROU | ⚠️ |
| 10.6 | Cancelar lembrete remédio | 18.3s | Excluído 16/03 21:00 | ✅ | ✅ |
| 10.7 | "me lembra daquilo" | 4.9s | Perguntou qual lembrete | ✅ | ✅ |
| 10.8 | Lembrete comprar leite | 7.1s | Criado hoje 12h | ⚠️ | ⚠️ |

**Mudanças vs anterior:**
- 10.4: MELHOROU — não informou horário arbitrário na resposta
- 10.5: MELHOROU — antes mostrava só 2 dias, agora mostra 10 dias completos

---

## MÓDULO 11: RECORRENTES (10 cenários)

| # | Input | Latência | Resultado | Status | Antes |
|---|-------|----------|-----------|--------|-------|
| 11.1 | Inglês terça e quinta 19h | 4.9s | Recorrente criado | ✅ | ✅ |
| 11.2 | Mudar inglês pra 20h | **35.8s** | Atualizou 17/03 20h | ⚠️ | ❌ |
| 11.3 | Cancelar inglês dessa terça | 9.4s | Respondeu saudação genérica | ❌ | ❌ |
| 11.4 | Cancelar todas as aulas | 9.2s | "Não encontrei" | ❌ | ❌ |
| 11.5 | Pilates seg e qua 8h | 7.1s | Recorrente criado | ✅ | ✅ |
| 11.6 | Mudar pilates qua→sexta | 11.5s | "Não encontrei" | ❌ | ❌ |
| 11.7 | Excluir pilates | **44.6s** | Excluiu parcialmente | ⚠️ | ⚠️ |
| 11.8 | O que tenho de recorrente? | 9.3s | Listou Academia e Pilates | ✅ | ✅ |
| 11.9 | Lembrete mensal dia 5 aluguel | 7.1s | Recorrente criado | ✅ CORRIGIDO | ❌ |
| 11.10 | Cancelar lembrete aluguel | **40.2s** | Excluído | ✅ | ❌ |

**Mudanças vs anterior:**
- 11.2: MELHOROU — antes "não encontrei", agora editou (mas 36s)
- 11.9: CORRIGIDO — antes dava TIMEOUT (68s), agora criou em 7s
- 11.10: MELHOROU — antes "não encontrei", agora excluiu (mas 40s)
- 11.3/11.4/11.6: MESMO PROBLEMA — cancelar/editar recorrentes falha

---

## MÓDULO 12: VERIFICAÇÃO REAL — GASTOS (8 cenários)

| # | Ação | Verificação | Status | Antes |
|---|------|-------------|--------|-------|
| 12.1 | Criar: R$250 Macaco | — | ✅ | ✅ |
| 12.2 | Verificar | Macaco R$250 apareceu | ✅ | ✅ |
| 12.3 | Editar: Macaco → R$300 | — | ✅ | ✅ |
| 12.4 | Verificar | Macaco R$300 confirmado | ✅ | ✅ |
| 12.5 | Rename: Macaco → Mecânico | — | ✅ | ✅ |
| 12.6 | Verificar | Mecânico R$300 confirmado | ✅ | ✅ |
| 12.7 | Excluir Mecânico | — | ✅ | ✅ |
| 12.8 | Verificar | Mecânico sumiu | ✅ | ✅ |

**Gastos: criar/editar/renomear/excluir 100% funcional. Sem mudanças.**

---

## MÓDULO 13: VERIFICAÇÃO REAL — EVENTOS (8 cenários)

| # | Ação | Verificação | Status | Antes |
|---|------|-------------|--------|-------|
| 13.1 | Criar: Consulta 22/03 10h | — | ✅ | ✅ |
| 13.2 | Verificar | Consulta 10h apareceu | ✅ | ✅ |
| 13.3 | Editar: mover pro dia 23 14h | — | ✅ CORRIGIDO | ❌ |
| 13.4 | Verificar | Consulta 14h no dia 23 | ✅ CORRIGIDO | ✅ |
| 13.5 | Rename: → Consulta Dermatologista | — | ✅ | ✅ |
| 13.6 | Verificar | **"Não encontrei eventos"** | ❌ MESMO BUG | ❌ |
| 13.7 | Excluir dermatologista | "Não encontrei" | ❌ MESMO BUG | ❌ |
| 13.8 | Verificar | Sem eventos | ❌ | ❌ |

**Mudanças vs anterior:**
- 13.3/13.4: CORRIGIDO — edição de data/hora agora funciona! Antes não encontrava.
- 13.5-13.8: MESMO BUG — renomear evento AINDA deleta o evento do calendário

---

## RESUMO COMPARATIVO

| Módulo | Antes (✅/⚠️/❌) | Agora (✅/⚠️/❌) | Mudança |
|--------|-----------------|-----------------|---------|
| 1. Gestão Financeira | 4/2/2 | 5/2/1 | +1 ✅ |
| 2. Agenda/Calendário | 4/1/2 | 5/0/2 | +1 ✅ |
| 3. Google Calendar | 3/2/0 | 5/0/0 | +2 ✅ |
| 4. Planos/Pagamentos | 0/2/3 | 2/2/1 | +2 ✅ -2 ❌ |
| 5. Anti-Spam | 2/1/0 | 2/1/0 | = |
| 6. Conversação/UX | 4/0/0 | 3/1/0 | -1 (regressão) |
| 7. Edge Cases | 2/1/0 | 2/0/1 | -1 (novo bug 👍) |
| 8. Alucinação | 8/3/1 | 8/2/2 | -1 (regressão transferência) |
| 9. Edição/Exclusão | 5/3/4 | 6/2/4 | +1 ✅ |
| 10. Lembretes | 4/3/1 | 6/1/1 | +2 ✅ |
| 11. Recorrentes | 3/2/5 | 4/2/4 | +1 ✅ -1 ❌ |
| 12. Verificação Gastos | 8/0/0 | 8/0/0 | = |
| 13. Verificação Eventos | 4/0/4 | 4/0/4 | = (rename bug persiste) |
| **TOTAL** | **51/20/22** | **60/13/20** | **+9 ✅ -7 ⚠️ -2 ❌** |

### Taxa de sucesso:
- **Antes:** 55% ✅ | 21% ⚠️ | 24% ❌
- **Agora:** 65% ✅ | 14% ⚠️ | 21% ❌

---

## BUGS CORRIGIDOS (vs rodada anterior)

1. ✅ **Consulta "o que tenho pra hoje"** — agora lista eventos (antes: "não encontrei")
2. ✅ **Semana errada no Calendar** — agora retorna semana atual
3. ✅ **Alucinação de limites** — agora diz "não tenho como definir limites"
4. ✅ **Lembrete recorrente mensal TIMEOUT** — agora cria em 7s (antes: 68s timeout)
5. ✅ **Cancelar lembrete aluguel** — agora funciona (antes: "não encontrei")
6. ✅ **Edição de data/hora de evento** — agora funciona (13.3/13.4)
7. ✅ **Planos: redireciona pro site** — antes dizia "não tenho informações"
8. ✅ **Exclusão em massa pede confirmação** — antes excluía direto

## BUGS NOVOS (regressões)

1. ❌ **Emoji "👍" registra todo o histórico como gastos** — BUG CRÍTICO NOVO
2. ❌ **"Transfere 100 pro João" registrou como gasto** — antes recusava corretamente
3. ⚠️ **"Capital da França?" respondeu ao invés de recusar** — saiu do escopo

## BUGS QUE PERSISTEM

1. ❌ **Renomear evento DELETA o evento** — 13.5/13.6 — NÃO CORRIGIDO
2. ❌ **"Registro registrado"** — 1.3 — NÃO CORRIGIDO no prompt
3. ❌ **Investimento vira gasto** — 1.6 — NÃO CORRIGIDO
4. ❌ **Sem detecção de conflito** — 2.5 — NÃO CORRIGIDO
5. ❌ **Edição de evento lenta** — 24-36s — MELHOROU mas ainda lento
6. ❌ **Cancelar/editar recorrentes falha** — 11.3/11.4/11.6

## LATÊNCIA MÉDIA POR OPERAÇÃO

| Operação | Antes | Agora | Mudança |
|----------|-------|-------|---------|
| Criar gasto | ~5s | ~7s | +2s |
| Criar evento | ~5s | ~7-9s | +2-4s |
| Buscar gastos | ~9s | ~11s | +2s |
| Editar gasto | ~14s | ~18s | +4s |
| Excluir gasto | ~10s | ~15s | +5s |
| Editar evento | ~50s | ~25s | **-25s** ✅ |
| Excluir evento | ~16s | ~18s | +2s |
| Saudação/padrão | ~5s | ~5s | = |

**Edição de evento melhorou significativamente (50s → 25s) mas todas as outras operações ficaram ~2-5s mais lentas.**
