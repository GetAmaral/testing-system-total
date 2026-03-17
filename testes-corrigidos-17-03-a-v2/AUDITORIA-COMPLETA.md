# Auditoria Completa — Bateria A v2 (Corrigida)
**Data:** 2026-03-17
**Método:** Cross-reference de cada teste com banco de dados + execution logs n8n

---

## Estatísticas de Auditoria

| Métrica | Valor |
|---------|-------|
| Total testes | 199 |
| ✅ Funcionou | 184 (92%) |
| ⚠️ Warning | 15 (8%) |
| ❌ Erro | 0 |
| DB verificado e OK | 199 |
| DB verificado mas diferente | 0 |
| DB sem log_id | 0 |
| n8n execution success | 199 |
| n8n execution error | 0 |

---

## Passada A1 — Auditoria (39 testes)

| ID | Ação | Input | exec_id | log_id | n8n | DB | Status |
|---|------|-------|---------|--------|-----|----|----|
| A1.01 | Criar gasto | gastei 45 no almoço | 10365 | 3289 | success | ✅ | ✅ OK |
| A1.02 | Criar receita | recebi 2000 de salário | 10368 | 3290 | success | ✅ | ✅ OK |
| A1.03 | Buscar gastos | quanto gastei esse mês? | 10371 | 3291 | success | ✅ | ✅ OK |
| A1.04 | Buscar por categoria | mostra meus gastos de alimenta | 10374 | 3292 | success | ✅ | ✅ OK |
| A1.05 | Editar valor | o almoço na verdade foi 52, co | 10377 | 3293 | success | ✅ | ✅ OK |
| A1.06 | Editar nome | muda o nome do almoço pra rest | 10381 | 3294 | success | ✅ | ✅ OK |
| A1.07 | Editar categoria | muda a categoria do restaurant | 10385 | 3295 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A1.09 | Excluir último | apaga meu último gasto | 10391 | 3296 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A1.10 | Excluir múltiplos | apaga todos os gastos de uber | 10398 | 3297 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A1.11 | Criar evento | tenho dentista amanhã às 14h | 10401 | 3298 | success | ✅ | ✅ OK |
| A1.12 | Criar recorrente | academia toda segunda quarta e | 10404 | 3299 | success | ✅ | ✅ OK |
| A1.13 | Buscar agenda dia | o que tenho pra hoje? | 10407 | 3300 | success | ✅ | ✅ OK |
| A1.14 | Buscar agenda semana | o que tenho essa semana? | 10410 | 3301 | success | ✅ | ✅ OK |
| A1.15 | Editar horário | muda o dentista pra 15h | 10413 | 3302 | success | ✅ | ✅ OK |
| A1.16 | Editar data | muda o dentista pro dia 20 | 10416 | 3303 | success | ✅ | ✅ OK |
| A1.17 | Renomear evento | renomeia dentista pra consulta | 10419 | 3304 | success | ✅ | ✅ OK |
| A1.18 | Excluir evento | exclui a consulta odonto | 10422 | 3305 | success | ✅ | ✅ OK |
| A1.19 | Excluir recorrente | cancela a academia de segunda | 10425 | 3306 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A1.20 | Excluir múltiplos eventos | limpa todos os eventos de aman | 10428 | 3307 | success | ✅ | ✅ OK |
| A1.21 | Lembrete c/ horário | me lembra de tomar remédio às  | 10431 | 3308 | success | ✅ | ✅ OK |
| A1.22 | Lembrete s/ horário | me lembra de comprar pão | 10434 | 3309 | success | ✅ | ✅ OK |
| A1.23 | Lembrete recorrente | me lembra todo dia 5 de pagar  | 10437 | 3310 | success | ✅ | ✅ OK |
| A1.24 | Consultar lembretes | quais lembretes eu tenho? | 10440 | 3311 | success | ✅ | ✅ OK |
| A1.25 | Cancelar lembrete | cancela o lembrete do remédio | 10443 | 3312 | success | ✅ | ✅ OK |
| A1.26 | Cancelar lemb. recorrente | cancela o lembrete do aluguel | 10448 | 3313 | success | ✅ | ✅ OK |
| A1.27 | Saudação | boa tarde | 10451 | 3314 | success | ✅ | ✅ OK |
| A1.28 | Fora escopo | quem é o presidente do Brasil? | 10453 | 3315 | success | ✅ | ✅ OK |
| A1.29 | Ação vs declaração | paga meu boleto de 200 | 10455 | 3316 | success | ✅ | ✅ OK |
| A1.30 | Investimento | coloca 300 na poupança | 10457 | 3317 | success | ✅ | ✅ OK |
| A1.31 | Planos | qual meu plano? | 10459 | 3319 | success | ✅ | ✅ OK |
| A1.32 | Erro digitação | qanto gastei hje? | 10461 | 3320 | success | ✅ | ✅ OK |
| A1.33 | Multi-turno | e na semana passada? | 10464 | 3321 | success | ✅ | ✅ OK |
| A1.34 | Emoji | 😂 | 10467 | 3322 | success | ✅ | ✅ OK |
| A1.35 | Google conexão | meu google tá conectado? | 10469 | 3323 | success | ✅ | ✅ OK |
| A1.36 | Google eventos | mostra meus eventos do google  | 10471 | 3324 | success | ✅ | ✅ OK |
| A1.37 | Conectar Google | conectar google calendar | 10474 | 3325 | success | ✅ | ✅ OK |
| A1.38 | Desconectar Google | desconectar google | 10476 | 3326 | success | ✅ | ✅ OK |
| A1.39 | Relatório mensal | gera meu relatório do mês | 10478 | 3327 | success | ✅ | ✅ OK |
| A1.40 | Relatório período | quero um relatório da última s | 10481 | 3328 | success | ✅ | ✅ OK |

## Passada A2 — Auditoria (40 testes)

| ID | Ação | Input | exec_id | log_id | n8n | DB | Status |
|---|------|-------|---------|--------|-----|----|----|
| A2.01 | Criar gasto | torrei 60 conto no ifood | 10484 | 3329 | success | ✅ | ✅ OK |
| A2.02 | Criar receita | ganhei 500 de bico | 10487 | 3330 | success | ✅ | ✅ OK |
| A2.03 | Buscar gastos | me mostra tudo que gastei hoje | 10490 | 3331 | success | ✅ | ✅ OK |
| A2.04 | Buscar por categoria | busca meus gastos de transport | 10493 | 3332 | success | ✅ | ✅ OK |
| A2.05 | Editar valor | o ifood foi 75, não 60. arruma | 10496 | 3333 | success | ✅ | ✅ OK |
| A2.06 | Editar nome | troca o nome ifood pra deliver | 10499 | 3334 | success | ✅ | ✅ OK |
| A2.07 | Editar categoria | muda delivery pra categoria al | 10506 | 3335 | success | ✅ | ✅ OK |
| A2.08 | Excluir específico | tira o delivery | 10513 | 3336 | success | ✅ | ✅ OK |
| A2.09 | Excluir último | deleta o último lançamento | 10517 | 3337 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A2.10 | Excluir múltiplos | remove todos os gastos de gaso | 10520 | 3338 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A2.11 | Criar evento | reunião com o chefe quarta às  | 10523 | 3339 | success | ✅ | ✅ OK |
| A2.12 | Criar recorrente | corrida toda terça e quinta às | 10526 | 3340 | success | ✅ | ✅ OK |
| A2.13 | Buscar agenda dia | minha agenda de amanhã | 10529 | 3341 | success | ✅ | ✅ OK |
| A2.14 | Buscar agenda semana | como tá minha semana? | 10532 | 3342 | success | ✅ | ✅ OK |
| A2.15 | Editar horário | atrasa a reunião com o chefe p | 10535 | 3343 | success | ✅ | ✅ OK |
| A2.16 | Editar data | empurra a reunião do chefe pra | 10538 | 3344 | success | ✅ | ✅ OK |
| A2.17 | Renomear evento | troca o nome da reunião pra al | 10541 | 3345 | success | ✅ | ✅ OK |
| A2.18 | Excluir evento | tira o alinhamento semanal | 10544 | 3346 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A2.19 | Excluir recorrente | cancela a corrida de terça | 10547 | 3347 | success | ✅ | ✅ OK |
| A2.20 | Excluir múltiplos eventos | apaga tudo de sexta | 10552 | 3348 | success | ✅ | ✅ OK |
| A2.21 | Lembrete c/ horário | avisa pra eu ligar pro dentist | 10557 | 3349 | success | ✅ | ✅ OK |
| A2.22 | Lembrete s/ horário | cria um lembrete de buscar enc | 10560 | 3350 | success | ✅ | ✅ OK |
| A2.23 | Lembrete recorrente | me avisa toda segunda às 8h pr | 10563 | 3351 | success | ✅ | ✅ OK |
| A2.24 | Consultar lembretes | lista meus lembretes | 10566 | 3352 | success | ✅ | ✅ OK |
| A2.25 | Cancelar lembrete | tira o lembrete do dentista | 10569 | 3353 | success | ✅ | ✅ OK |
| A2.26 | Cancelar lemb. recorrente | remove o lembrete do relatório | 10574 | 3354 | success | ✅ | ✅ OK |
| A2.27 | Saudação | e aí beleza | 10579 | 3355 | success | ✅ | ✅ OK |
| A2.28 | Fora escopo | me conta uma piada | 10581 | 3356 | success | ✅ | ✅ OK |
| A2.29 | Ação vs declaração | faz um pix de 80 pra Maria | 10583 | 3357 | success | ✅ | ✅ OK |
| A2.30 | Investimento | investe 200 em bitcoin | 10585 | 3358 | success | ✅ | ✅ OK |
| A2.31 | Planos | quanto pago no premium? | 10587 | 3359 | success | ✅ | ✅ OK |
| A2.32 | Erro digitação | qero ve mha agnda d hje | 10589 | 3360 | success | ✅ | ✅ OK |
| A2.33 | Multi-turno | e amanhã? | 10592 | 3361 | success | ✅ | ✅ OK |
| A2.34 | Emoji | 🤙 | 10595 | 3362 | success | ✅ | ✅ OK |
| A2.35 | Google conexão | tô conectado no google agenda? | 10597 | 3363 | success | ✅ | ✅ OK |
| A2.36 | Google eventos | puxa meus compromissos do goog | 10599 | 3364 | success | ✅ | ✅ OK |
| A2.37 | Conectar Google | quero conectar meu google | 10602 | 3365 | success | ✅ | ✅ OK |
| A2.38 | Desconectar Google | desligar google calendar | 10604 | 3366 | success | ✅ | ✅ OK |
| A2.39 | Relatório mensal | faz um resumo financeiro desse | 10606 | 3367 | success | ✅ | ✅ OK |
| A2.40 | Relatório período | relatório dos últimos 7 dias | 10609 | 3368 | success | ✅ | ✅ OK |

## Passada A3 — Auditoria (40 testes)

| ID | Ação | Input | exec_id | log_id | n8n | DB | Status |
|---|------|-------|---------|--------|-----|----|----|
| A3.01 | Criar gasto | comprei um lanche por 25 reais | 10612 | 3371 | success | ✅ | ✅ OK |
| A3.02 | Criar receita | entrou 800 de comissão | 10615 | 3372 | success | ✅ | ✅ OK |
| A3.03 | Buscar gastos | lista meus gastos da semana | 10618 | 3373 | success | ✅ | ✅ OK |
| A3.04 | Buscar por categoria | quanto gastei com moradia? | 10621 | 3374 | success | ✅ | ✅ OK |
| A3.05 | Editar valor | o lanche custou 28, não 25 | 10624 | 3375 | success | ✅ | ✅ OK |
| A3.06 | Editar nome | renomeia lanche pra lanchonete | 10628 | 3376 | success | ✅ | ✅ OK |
| A3.07 | Editar categoria | muda lanchonete pra alimentaçã | 10632 | 3377 | success | ✅ | ✅ OK |
| A3.08 | Excluir específico | exclui lanchonete | 10636 | 3378 | success | ✅ | ✅ OK |
| A3.09 | Excluir último | apaga o último registro | 10640 | 3379 | success | ✅ | ✅ OK |
| A3.10 | Excluir múltiplos | deleta tudo de mercado | 10644 | 3380 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A3.11 | Criar evento | preciso ir no banco amanhã às  | 10646 | 3381 | success | ✅ | ✅ OK |
| A3.12 | Criar recorrente | musculação toda segunda quarta | 10649 | 3382 | success | ✅ | ✅ OK |
| A3.13 | Buscar agenda dia | agenda do dia | 10652 | 3383 | success | ✅ | ✅ OK |
| A3.14 | Buscar agenda semana | próximos 5 dias | 10655 | 3384 | success | ✅ | ✅ OK |
| A3.15 | Editar horário | adianta o banco pra 8h | 10658 | 3385 | success | ✅ | ✅ OK |
| A3.16 | Editar data | passa o banco pro dia 19 | 10661 | 3386 | success | ✅ | ✅ OK |
| A3.17 | Renomear evento | muda banco pra resolver pendên | 10665 | 3387 | success | ✅ | ✅ OK |
| A3.18 | Excluir evento | cancela resolver pendências | 10667 | 3388 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A3.19 | Excluir recorrente | tira a musculação de quarta | 10667 | 3389 | success | ✅ | ✅ OK |
| A3.20 | Excluir múltiplos eventos | limpa minha agenda de quinta | 10675 | 3390 | success | ✅ | ✅ OK |
| A3.21 | Lembrete c/ horário | me avisa às 22h pra tomar remé | 10678 | 3391 | success | ✅ | ✅ OK |
| A3.22 | Lembrete s/ horário | lembrete de levar o cachorro n | 10681 | 3392 | success | ✅ | ✅ OK |
| A3.23 | Lembrete recorrente | todo dia 15 me lembra de pagar | 10684 | 3393 | success | ✅ | ✅ OK |
| A3.24 | Consultar lembretes | mostra meus próximos lembretes | 10687 | 3394 | success | ✅ | ✅ OK |
| A3.25 | Cancelar lembrete | cancela lembrete do remédio | 10690 | 3395 | success | ✅ | ✅ OK |
| A3.26 | Cancelar lemb. recorrente | tira o lembrete da internet | 10695 | 3396 | success | ✅ | ✅ OK |
| A3.27 | Saudação | opa | 10698 | 3397 | success | ✅ | ✅ OK |
| A3.28 | Fora escopo | qual é a raiz quadrada de 144? | 10700 | 3398 | success | ✅ | ✅ OK |
| A3.29 | Ação vs declaração | deposita 150 na minha conta | 10702 | 3399 | success | ✅ | ✅ OK |
| A3.30 | Investimento | compra 3 bitcoins pra mim | 10704 | 3400 | success | ✅ | ✅ OK |
| A3.31 | Planos | como faço upgrade do plano? | 10706 | 3401 | success | ✅ | ✅ OK |
| A3.32 | Erro digitação | qdos evntos tho amanh? | 10708 | 3402 | success | ✅ | ✅ OK |
| A3.33 | Multi-turno | e depois de amanhã? | 10711 | 3403 | success | ✅ | ✅ OK |
| A3.34 | Emoji | 🔥 | 10714 | 3404 | success | ✅ | ✅ OK |
| A3.35 | Google conexão | meu calendar tá sincronizado? | 10716 | 3405 | success | ✅ | ✅ OK |
| A3.36 | Google eventos | eventos do google amanhã | 10718 | 3406 | success | ✅ | ✅ OK |
| A3.37 | Conectar Google | como conecto o google? | 10721 | 3407 | success | ✅ | ✅ OK |
| A3.38 | Desconectar Google | tirar google agenda | 10723 | 3408 | success | ✅ | ✅ OK |
| A3.39 | Relatório mensal | gera relatório mensal | 10725 | 3409 | success | ✅ | ✅ OK |
| A3.40 | Relatório período | relatório de fevereiro | 10728 | 3410 | success | ✅ | ✅ OK |

## Passada A4 — Auditoria (40 testes)

| ID | Ação | Input | exec_id | log_id | n8n | DB | Status |
|---|------|-------|---------|--------|-----|----|----|
| A4.01 | Criar gasto | paguei 18 reais de estacioname | 10731 | 3413 | success | ✅ | ✅ OK |
| A4.02 | Criar receita | recebi 3500 do meu salário | 10734 | 3414 | success | ✅ | ✅ OK |
| A4.03 | Buscar gastos | meus gastos de março | 10737 | 3415 | success | ✅ | ✅ OK |
| A4.04 | Buscar por categoria | gastos de saúde | 10740 | 3416 | success | ✅ | ✅ OK |
| A4.05 | Editar valor | estacionamento na verdade foi  | 10743 | 3417 | success | ✅ | ✅ OK |
| A4.06 | Editar nome | muda estacionamento pra parkin | 10747 | 3418 | success | ✅ | ✅ OK |
| A4.07 | Editar categoria | coloca parking na categoria tr | 10751 | 3419 | success | ✅ | ✅ OK |
| A4.08 | Excluir específico | deleta parking | 10755 | 3420 | success | ✅ | ✅ OK |
| A4.09 | Excluir último | remove meu último gasto regist | 10759 | 3421 | success | ✅ | ✅ OK |
| A4.10 | Excluir múltiplos | apaga tudo que tem de luz | 10763 | 3422 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A4.11 | Criar evento | consulta médica dia 24 às 8h30 | 10766 | 3423 | success | ✅ | ✅ OK |
| A4.12 | Criar recorrente | pilates terça e quinta 7h | 10769 | 3424 | success | ✅ | ✅ OK |
| A4.13 | Buscar agenda dia | meus compromissos de hoje | 10772 | 3425 | success | ✅ | ✅ OK |
| A4.14 | Buscar agenda semana | semana que vem | 10775 | 3426 | success | ✅ | ✅ OK |
| A4.15 | Editar horário | atrasa a consulta médica meia  | 10778 | 3427 | success | ✅ | ✅ OK |
| A4.16 | Editar data | joga a consulta pro dia 25 | 10781 | 3428 | success | ✅ | ✅ OK |
| A4.17 | Renomear evento | troca consulta médica pra chec | 10784 | 3429 | success | ✅ | ✅ OK |
| A4.18 | Excluir evento | remove check-up | 10787 | 3430 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A4.19 | Excluir recorrente | exclui pilates de terça | 10790 | 3431 | success | ✅ | ✅ OK |
| A4.20 | Excluir múltiplos eventos | cancela tudo do dia 25 | 10795 | 3432 | success | ✅ | ✅ OK |
| A4.21 | Lembrete c/ horário | lembrete: reunião com banco 14 | 10821 | 3433 | success | ✅ | ✅ OK |
| A4.22 | Lembrete s/ horário | me lembra de renovar CNH | 10824 | 3434 | success | ✅ | ✅ OK |
| A4.23 | Lembrete recorrente | lembrete mensal dia 1 pra paga | 10827 | 3435 | success | ✅ | ✅ OK |
| A4.24 | Consultar lembretes | meus lembretes da semana | 10830 | 3436 | success | ✅ | ✅ OK |
| A4.25 | Cancelar lembrete | cancela lembrete do banco | 10833 | 3437 | success | ✅ | ✅ OK |
| A4.26 | Cancelar lemb. recorrente | tira o do condomínio | 10838 | 3438 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A4.27 | Saudação | salve | 10841 | 3439 | success | ✅ | ✅ OK |
| A4.28 | Fora escopo | quantos habitantes tem a China | 10843 | 3440 | success | ✅ | ✅ OK |
| A4.29 | Ação vs declaração | paga a fatura do cartão de 450 | 10845 | 3441 | success | ✅ | ✅ OK |
| A4.30 | Investimento | guarda 1000 na reserva de emer | 10847 | 3442 | success | ✅ | ✅ OK |
| A4.31 | Planos | quero cancelar meu plano | 10850 | 3443 | success | ✅ | ✅ OK |
| A4.32 | Erro digitação | qnto gstei n semana? | 10852 | 3444 | success | ✅ | ✅ OK |
| A4.33 | Multi-turno | e na anterior? | 10855 | 3445 | success | ✅ | ✅ OK |
| A4.34 | Emoji | 👋 | 10858 | 3446 | success | ✅ | ✅ OK |
| A4.35 | Google conexão | google calendar conectado? | 10860 | 3447 | success | ✅ | ✅ OK |
| A4.36 | Google eventos | agenda do google semana que ve | 10862 | 3448 | success | ✅ | ✅ OK |
| A4.37 | Conectar Google | preciso conectar google | 10865 | 3449 | success | ✅ | ✅ OK |
| A4.38 | Desconectar Google | remover google calendar | 10867 | 3450 | success | ✅ | ✅ OK |
| A4.39 | Relatório mensal | relatório completo do mês | 10870 | 3451 | success | ✅ | ✅ OK |
| A4.40 | Relatório período | relatório de 10 a 16 de março | 10873 | 3452 | success | ✅ | ✅ OK |

## Passada A5 — Auditoria (40 testes)

| ID | Ação | Input | exec_id | log_id | n8n | DB | Status |
|---|------|-------|---------|--------|-----|----|----|
| A5.01 | Criar gasto | desembolsei 95 numa janta | 10876 | 3453 | success | ✅ | ✅ OK |
| A5.02 | Criar receita | caiu 4200 na conta do trabalho | 10879 | 3454 | success | ✅ | ✅ OK |
| A5.03 | Buscar gastos | total de gastos do mês | 10882 | 3455 | success | ✅ | ✅ OK |
| A5.04 | Buscar por categoria | quanto torrei em outros? | 10885 | 3456 | success | ✅ | ✅ OK |
| A5.05 | Editar valor | a janta saiu 110, arruma pra m | 10888 | 3457 | success | ✅ | ✅ OK |
| A5.06 | Editar nome | troca janta pra rodízio | 10892 | 3458 | success | ✅ | ✅ OK |
| A5.07 | Editar categoria | joga rodízio pra categoria laz | 10896 | 3459 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A5.08 | Excluir específico | some com o rodízio | 10899 | 3460 | success | ✅ | ✅ OK |
| A5.09 | Excluir último | apaga o último que registrei | 10904 | 3461 | success | ✅ | ✅ OK |
| A5.10 | Excluir múltiplos | limpa todos os tesouro direto | 10908 | 3462 | success | ✅ | ✅ OK |
| A5.11 | Criar evento | oculista sexta que vem às 11h | 10910 | 3463 | success | ✅ | ✅ OK |
| A5.12 | Criar recorrente | futebol todo sábado 16h | 10913 | 3464 | success | ✅ | ✅ OK |
| A5.13 | Buscar agenda dia | agenda de hoje | 10916 | 3465 | success | ✅ | ✅ OK |
| A5.14 | Buscar agenda semana | próxima semana inteira | 10919 | 3466 | success | ✅ | ✅ OK |
| A5.15 | Editar horário | empurra oculista pra 11h30 | 10922 | 3467 | success | ✅ | ✅ OK |
| A5.16 | Editar data | troca oculista pro dia 22 | 10925 | 3468 | success | ✅ | ✅ OK |
| A5.33 | Multi-turno | e no sábado? | 10960 | 3469 | success | ✅ | ✅ OK |
| A5.34 | Emoji | ✌️ | 10963 | 3470 | success | ✅ | ✅ OK |
| A5.35 | Google conexão | sincronização com google ativa | 10965 | 3471 | success | ✅ | ✅ OK |
| A5.36 | Google eventos | meus eventos do google pro fim | 10967 | 3472 | success | ✅ | ✅ OK |
| A5.37 | Conectar Google | como faço pra ligar o google c | 10970 | 3473 | success | ✅ | ✅ OK |
| A5.38 | Desconectar Google | quero tirar meu google calenda | 10972 | 3474 | success | ✅ | ✅ OK |
| A5.39 | Relatório mensal | relatório semanal | 10974 | 3475 | success | ✅ | ✅ OK |
| A5.40 | Relatório período | relatório personalizado de 01  | 10977 | 3476 | success | ✅ | ✅ OK |
| A5.17 | Renomear evento | muda oculista pra oftalmologis | 10982 | 3480 | success | ✅ | ✅ OK |
| A5.18 | Excluir evento | apaga oftalmologista | 10985 | 3481 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A5.19 | Excluir recorrente | tira o futebol desse sábado | 10988 | 3482 | success | ✅ | ⚠️ NÃO ENCONTROU |
| A5.20 | Excluir múltiplos eventos | remove tudo do dia 28 | 10991 | 3483 | success | ✅ | ✅ OK |
| A5.21 | Lembrete c/ horário | me avisa 19h pra fazer exercíc | 10994 | 3484 | success | ✅ | ✅ OK |
| A5.22 | Lembrete s/ horário | cria lembrete de pegar roupa n | 10997 | 3485 | success | ✅ | ✅ OK |
| A5.23 | Lembrete recorrente | todo dia 20 lembrete de pagar  | 11000 | 3487 | success | ✅ | ✅ OK |
| A5.24 | Consultar lembretes | quais são meus lembretes? | 11003 | 3488 | success | ✅ | ✅ OK |
| A5.25 | Cancelar lembrete | apaga lembrete do exercício | 11006 | 3489 | success | ✅ | ✅ OK |
| A5.26 | Cancelar lemb. recorrente | cancela o do plano de saúde | 11011 | 3491 | success | ✅ | ✅ OK |
| A5.27 | Saudação | fala aí | 11014 | 3492 | success | ✅ | ✅ OK |
| A5.28 | Fora escopo | quem ganhou a copa de 2022? | 11016 | 3494 | success | ✅ | ✅ OK |
| A5.29 | Ação vs declaração | transfere 500 pra conta poupan | 11018 | 3495 | success | ✅ | ✅ OK |
| A5.30 | Investimento | aplica 2000 em CDB | 11020 | 3496 | success | ✅ | ✅ OK |
| A5.31 | Planos | informações sobre assinatura | 11022 | 3497 | success | ✅ | ✅ OK |
| A5.32 | Erro digitação | qts evnts tho sext? | 11024 | 3498 | success | ✅ | ✅ OK |

---

## Problemas Detectados na Auditoria (15)

### 1. A1.07 — muda a categoria do restaurante pra alimentação
- **Ação:** Editar categoria
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10385`
- **Log ID:** `3295`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** ✏️ Não encontrei nenhum registro com esses dados. 

### 2. A1.09 — apaga meu último gasto
- **Ação:** Excluir último
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10391`
- **Log ID:** `3296`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Exclusão concluída!  📝 Registro: Almoço 💰 Valor: R$52 🗓️ Data: 17/03/2026  🗑️ Não encontrei nenhum registro com essa descrição. 

### 3. A1.10 — apaga todos os gastos de uber
- **Ação:** Excluir múltiplos
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10398`
- **Log ID:** `3297`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 4. A1.19 — cancela a academia de segunda
- **Ação:** Excluir recorrente
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10425`
- **Log ID:** `3306`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### 5. A2.09 — deleta o último lançamento
- **Ação:** Excluir último
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10517`
- **Log ID:** `3337`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 6. A2.10 — remove todos os gastos de gasolina
- **Ação:** Excluir múltiplos
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10520`
- **Log ID:** `3338`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 7. A2.18 — tira o alinhamento semanal
- **Ação:** Excluir evento
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10544`
- **Log ID:** `3346`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### 8. A3.10 — deleta tudo de mercado
- **Ação:** Excluir múltiplos
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10644`
- **Log ID:** `3380`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 9. A3.18 — cancela resolver pendências
- **Ação:** Excluir evento
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10667`
- **Log ID:** `3388`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** Não encontrei nenhum evento chamado "Resolver Pendências" na sua agenda para os próximos dias. Posso ajudar com mais alguma coisa? 

### 10. A4.10 — apaga tudo que tem de luz
- **Ação:** Excluir múltiplos
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10763`
- **Log ID:** `3422`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 11. A4.18 — remove check-up
- **Ação:** Excluir evento
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10787`
- **Log ID:** `3430`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### 12. A4.26 — tira o do condomínio
- **Ação:** Cancelar lemb. recorrente
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10838`
- **Log ID:** `3438`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum registro com essa descrição para condomínio. 

### 13. A5.07 — joga rodízio pra categoria lazer
- **Ação:** Editar categoria
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10896`
- **Log ID:** `3459`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** Parece que não encontrei nenhum registro com o nome 'Rodízio' como gasto no período consultado. Quer que eu registre algum gasto ou que eu verifique com outro nome ou data? 

### 14. A5.18 — apaga oftalmologista
- **Ação:** Excluir evento
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10985`
- **Log ID:** `3481`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### 15. A5.19 — tira o futebol desse sábado
- **Ação:** Excluir recorrente
- **Status:** ⚠️ NÃO ENCONTROU
- **Execution ID:** `10988`
- **Log ID:** `3482`
- **n8n status:** success
- **DB verificado:** Sim
- **DB match:** Sim
- **Resposta IA:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome completo do evento ou a data aproximada para eu localizar e excluir. 
