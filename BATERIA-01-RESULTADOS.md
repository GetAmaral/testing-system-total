# Bateria de Testes #01 — Total Assistente
**Data:** 2026-03-15
**Ambiente:** N8N Dev (http://76.13.172.17:5678)
**Usuário teste:** Luiz Felipe (554391936205 / animadoluiz@gmail.com)

---

## MÓDULO 1: GESTÃO FINANCEIRA (8 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 1.1 | "gastei 50 reais no mercado" | 7.3s | ✅ Gasto registrado! Nome: Mercado, R$50, Categoria: Alimentação | ✅ OK | — |
| 1.2 | "paguei 200 de luz" | 4.9s | ✅ Gasto registrado! Nome: Luz, R$200, Categoria: Moradia | ✅ OK | Categorização correta |
| 1.3 | "recebi 3000 de salário" | 7.4s | ✅ Registro registrado! Nome: Salário, R$3000, Categoria: Outros | ⚠️ | "Registro registrado" é redundante. Categoria deveria ser "Renda/Salário", não "Outros" |
| 1.4 | "quanto gastei esse mês?" | 7.1s | Exibiu extrato com saldo, saídas e entradas | ⚠️ | Exibiu registros com nomes ofensivos de testes antigos. Falta filtro de conteúdo |
| 1.5 | "quero gastar no máximo 500 em alimentação" | 5.0s | "Entendi seu limite... posso ajudar a controlar" | ⚠️ | Resposta vaga. Não confirmou se salvou. Feature de limites será removida |
| 1.6 | "investi 1000 em tesouro direto" | 4.9s | ✅ Gasto registrado! Nome: Tesouro Direto, R$1000, Categoria: Outros | ❌ BUG | Registrou investimento como GASTO. Tabela `investments` não foi usada |
| 1.7 | "torrei 80 conto no ifood ontem" | 4.9s | ✅ Gasto registrado! Nome: Ifood, R$80, Categoria: Alimentação | ✅ OK | Entendeu gíria brasileira |
| 1.8 | "gastei dez conto no uber" | 4.9s | ✅ Gasto registrado! Nome: Uber, R$10, Categoria: Transporte | ✅ OK | Entendeu valor por extenso |

### Bugs encontrados:
1. **"Registro registrado!"** — Texto redundante para entradas/receitas
2. **Categoria "Outros" para salário** — Deveria ter categoria "Renda" ou "Salário"
3. **Investimentos viram gastos** — Tabela `investments` existe mas não é usada
4. **Conteúdo ofensivo no extrato** — Nomes de gastos de teste sem filtro

---

## MÓDULO 2: AGENDA/CALENDÁRIO (7 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 2.1 | "tenho dentista amanhã às 14h" | 7.2s | ✅ Evento agendado! Dentista 16/03 às 14:00 | ✅ OK | — |
| 2.2 | "academia toda seg/qua/sex às 7h" | 4.9s | ✅ Evento recorrente registrado! | ✅ OK | Recorrência funcionou |
| 2.3 | "o que tenho pra hoje?" | 7.1s | "Não encontrei eventos nesse período" | ⚠️ | Deveria ter listado eventos criados anteriormente |
| 2.4 | "preciso resolver negócio do banco semana que vem" | 4.9s | Pediu confirmação de dia/horário | ✅ OK | Bom UX — não agendou sem confirmar |
| 2.5 | "reunião amanhã às 14h" (conflito com dentista 2.1) | 4.9s | ✅ Evento agendado! Reunião 16/03 às 14:00 | ❌ BUG | NÃO detectou conflito com dentista no mesmo horário |
| 2.6 | "me lembra de pagar boleto dia 20" | 5.0s | ✅ Lembrete criado | ✅ OK | — |
| 2.7 | "cancela minha reunião de amanhã" | 16.2s | 🗑️ Evento excluído! Reunião 16/03 14:00-14:30 | ✅ OK | Funcionou mas latência alta (16s) |

### Bugs encontrados:
1. **Sem detecção de conflito de horário** — Agendou 2 eventos no mesmo horário sem avisar
2. **Consulta de "hoje" não retornou eventos** — Possível problema de timezone ou filtro
3. **Cancelamento lento** — 16s vs ~5s dos outros testes

---

## MÓDULO 3: GOOGLE CALENDAR SYNC (5 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 3.1 | "meu google calendar tá conectado?" | 4.8s | "Sim, está conectado" | ✅ OK | — |
| 3.2 | "agendar reunião dia 20 às 15h + sync google" | 4.9s | ✅ Evento agendado! Reunião Importante 20/03 15:00 | ⚠️ | Não confirmou se sincronizou com Google |
| 3.3 | "desconectar google calendar" | 4.9s | "Não consigo desconectar aqui, acesse totalassistente.com.br" | ✅ OK | Correto redirecionar |
| 3.4 | "quais eventos essa semana?" | 11.5s | Listou agenda de 09/03 a 15/03 | ⚠️ | Retornou semana PASSADA ao invés da semana ATUAL |
| 3.5 | "conectar google calendar" | 4.9s | "Acesse totalassistente.com.br na aba Agenda" | ✅ OK | — |

### Bugs encontrados:
1. **Semana errada na consulta** — "essa semana" retornou 09-15/03 (passada) ao invés da atual
2. **UX de conexão Google** — Usuários não entendem que precisam ir ao site. Precisa de solução melhor

---

## MÓDULO 4: PLANOS E PAGAMENTOS (5 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 4.1 | "qual meu plano?" | 4.9s | "Não trabalho com planos específicos" | ❌ BUG | O sistema TEM planos (free/standard/premium). IA não conhece o produto |
| 4.2 | "quero ver relatório completo com gráficos" | 7.1s | "Seu relatório está sendo gerado 🔃" | ⚠️ | Não sabemos se entregou de fato |
| 4.3 | "quanto custa o premium?" | 4.9s | "Não tenho informações sobre planos ou preços" | ❌ BUG | Deveria informar preços ou redirecionar |
| 4.4 | "cancelar assinatura" | 4.9s | "Não tenho acesso para cancelar" | ❌ BUG | Deveria guiar ao processo correto |
| 4.5 | "último pagamento aprovado?" | 4.9s | Falou sobre último lançamento financeiro | ⚠️ | Confundiu pagamento do plano com lançamento de gasto |

### Bugs encontrados:
1. **IA desconhece o próprio produto** — Não sabe sobre planos, preços, assinatura
2. **Não guia o usuário** — Deveria redirecionar para o site ou dar instruções claras

---

## MÓDULO 5: ANTI-SPAM E RATE LIMITING (4 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 5.1 | "oi" 5x seguidas | ~4.9s cada | Respondeu todas as 5 com variações | ⚠️ | Nenhum rate limit ativou. Variou texto (bom) mas não bloqueou |
| 5.3 | Spam 5000+ chars | 4.9s | "Parece mensagem longa repetida" | ✅ OK | Tratou bem |
| 5.4 | Link suspeito + golpe | 4.9s | "Não posso ajudar com esse tipo de conteúdo" | ✅ OK | Recusou corretamente |

### Bugs encontrados:
1. **Sem rate limiting efetivo** — 5 mensagens seguidas sem bloqueio. Tabela `bot_blocks` e `rate_limits` não foram acionadas

---

## MÓDULO 6: CONVERSAÇÃO E UX (4 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 6.1 | "bom dia" | 4.9s | "Bom dia! Como posso ajudar?" | ✅ OK | Tom amigável |
| 6.2 | "qual a capital da França?" | 4.9s | "Pergunta geral, fora do que consigo fazer" | ✅ OK | Recusou educadamente |
| 6.3 | "qunto gastei esi mes?" | 9.3s | Entendeu e exibiu extrato | ✅ OK | Tolerância a erros de digitação |
| 6.4 | "e no mês passado?" | 4.9s | Entendeu contexto, buscou mês anterior | ✅ OK | Multi-turno funcionou |

---

## MÓDULO 7: EDGE CASES E GARGALOS (3 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 7.1 | " " (espaço vazio) | 4.9s | "Oi! Precisa de ajuda?" | ✅ OK | Tratou graciosamente |
| 7.2 | "👍" (emoji) | 5.1s | "Se quiser registrar algo, é só falar" | ✅ OK | Tratou graciosamente |
| 7.3 | Mensagem longa com múltiplos gastos | 4.9s | Ofereceu criar eventos recorrentes | ⚠️ | Não registrou gastos na hora, apenas ofereceu ajuda futura |

---

## RESUMO GERAL

| Módulo | Total | ✅ OK | ⚠️ Atenção | ❌ Bug |
|--------|-------|-------|------------|--------|
| 1. Gestão Financeira | 8 | 4 | 2 | 2 |
| 2. Agenda/Calendário | 7 | 4 | 1 | 2 |
| 3. Google Calendar Sync | 5 | 3 | 2 | 0 |
| 4. Planos e Pagamentos | 5 | 0 | 2 | 3 |
| 5. Anti-spam | 3 | 2 | 1 | 0 |
| 6. Conversação e UX | 4 | 4 | 0 | 0 |
| 7. Edge Cases | 3 | 2 | 1 | 0 |
| **TOTAL** | **35** | **19 (54%)** | **9 (26%)** | **7 (20%)** |

### Latência média: ~5.5s (aceitável)
### Latência máxima: 16.2s (cancelamento de evento — investigar)

---

## BUGS CRÍTICOS POR PRIORIDADE

### P0 — Corrigir imediatamente
1. **IA não conhece o próprio produto** — Não sabe sobre planos, preços, cancelamento
2. **Sem detecção de conflito de horário** — Agenda 2 eventos no mesmo horário

### P1 — Corrigir em breve
3. **Investimentos registrados como gastos** — Tabela `investments` não é usada
4. **"Registro registrado"** — Texto redundante para receitas
5. **Semana errada no calendar** — Consulta retorna semana passada
6. **UX de conexão Google Calendar** — Usuário não entende que precisa ir ao site

### P2 — Melhorias
7. **Categoria "Outros" para salário** — Deveria ser "Renda"
8. **Rate limiting não ativa** — Nenhum bloqueio após 5 mensagens seguidas
9. **Filtro de conteúdo** — Aceita nomes ofensivos em registros financeiros
