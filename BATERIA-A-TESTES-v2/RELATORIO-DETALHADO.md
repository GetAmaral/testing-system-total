# Bateria A v2 — Relatório Detalhado
**Data:** 2026-03-17
**Total:** 199 testes | 5 passadas x ~40 ações
**Rastreabilidade:** Cada teste com execution ID (n8n) e log ID (Supabase)

---

## Estatísticas Gerais

| Métrica | Valor |
|---------|-------|
| Total de testes | 199 |
| ✅ Sucesso | 184 (92%) |
| ⚠️ Warning | 15 (8%) |
| ❌ Erro | 0 |
| Timeouts | 0 |

---

### Passada A1 (39 testes: 35✅ 4⚠️ 0❌)

| ID | Ação | Input | exec_id | log_id | Status |
|---|------|-------|---------|--------|--------|
| A1.01 | Criar gasto | gastei 45 no almoço | 10365 | 3289 | ✅ |
| A1.02 | Criar receita | recebi 2000 de salário | 10368 | 3290 | ✅ |
| A1.03 | Buscar gastos (período) | quanto gastei esse mês? | 10371 | 3291 | ✅ |
| A1.04 | Buscar gastos (categoria) | mostra meus gastos de alimentação | 10374 | 3292 | ✅ |
| A1.05 | Editar valor gasto | o almoço na verdade foi 52, corrige | 10377 | 3293 | ✅ |
| A1.06 | Editar nome gasto | muda o nome do almoço pra restaurante | 10381 | 3294 | ✅ |
| A1.07 | Editar categoria gasto | muda a categoria do restaurante pra alimentação | 10385 | 3295 | ⚠️ |
| A1.09 | Excluir último gasto | apaga meu último gasto | 10391 | 3296 | ⚠️ |
| A1.10 | Excluir múltiplos gastos | apaga todos os gastos de uber | 10398 | 3297 | ⚠️ |
| A1.11 | Criar evento pontual | tenho dentista amanhã às 14h | 10401 | 3298 | ✅ |
| A1.12 | Criar evento recorrente | academia toda segunda quarta e sexta às 7h | 10404 | 3299 | ✅ |
| A1.13 | Buscar agenda dia | o que tenho pra hoje? | 10407 | 3300 | ✅ |
| A1.14 | Buscar agenda semana | o que tenho essa semana? | 10410 | 3301 | ✅ |
| A1.15 | Editar horário evento | muda o dentista pra 15h | 10413 | 3302 | ✅ |
| A1.16 | Editar data evento | muda o dentista pro dia 20 | 10416 | 3303 | ✅ |
| A1.17 | Renomear evento | renomeia dentista pra consulta odonto | 10419 | 3304 | ✅ |
| A1.18 | Excluir evento | exclui a consulta odonto | 10422 | 3305 | ✅ |
| A1.19 | Excluir evento recorrente | cancela a academia de segunda | 10425 | 3306 | ⚠️ |
| A1.20 | Excluir múltiplos eventos | limpa todos os eventos de amanhã | 10428 | 3307 | ✅ |
| A1.21 | Criar lembrete c/ horário | me lembra de tomar remédio às 20h | 10431 | 3308 | ✅ |
| A1.22 | Criar lembrete s/ horário | me lembra de comprar pão | 10434 | 3309 | ✅ |
| A1.23 | Criar lembrete recorrente | me lembra todo dia 5 de pagar o aluguel | 10437 | 3310 | ✅ |
| A1.24 | Consultar lembretes | quais lembretes eu tenho? | 10440 | 3311 | ✅ |
| A1.25 | Cancelar lembrete | cancela o lembrete do remédio | 10443 | 3312 | ✅ |
| A1.26 | Cancelar lembrete recorrente | cancela o lembrete do aluguel | 10448 | 3313 | ✅ |
| A1.27 | Saudação | boa tarde | 10451 | 3314 | ✅ |
| A1.28 | Fora do escopo | quem é o presidente do Brasil? | 10453 | 3315 | ✅ |
| A1.29 | Ação vs declaração | paga meu boleto de 200 | 10455 | 3316 | ✅ |
| A1.30 | Investimento/poupança | coloca 300 na poupança | 10457 | 3317 | ✅ |
| A1.31 | Planos/preços | qual meu plano? | 10459 | 3319 | ✅ |
| A1.32 | Erro digitação | qanto gastei hje? | 10461 | 3320 | ✅ |
| A1.33 | Multi-turno | e na semana passada? | 10464 | 3321 | ✅ |
| A1.34 | Emoji | 😂 | 10467 | 3322 | ✅ |
| A1.35 | Verificar conexão Google | meu google tá conectado? | 10469 | 3323 | ✅ |
| A1.36 | Consultar eventos Google | mostra meus eventos do google essa semana | 10471 | 3324 | ✅ |
| A1.37 | Conectar Google | conectar google calendar | 10474 | 3325 | ✅ |
| A1.38 | Desconectar Google | desconectar google | 10476 | 3326 | ✅ |
| A1.39 | Relatório mensal | gera meu relatório do mês | 10478 | 3327 | ✅ |
| A1.40 | Relatório por período | quero um relatório da última semana | 10481 | 3328 | ✅ |

### Passada A2 (40 testes: 37✅ 3⚠️ 0❌)

| ID | Ação | Input | exec_id | log_id | Status |
|---|------|-------|---------|--------|--------|
| A2.01 | Criar gasto | torrei 60 conto no ifood | 10484 | 3329 | ✅ |
| A2.02 | Criar receita | ganhei 500 de bico | 10487 | 3330 | ✅ |
| A2.03 | Buscar gastos (período) | me mostra tudo que gastei hoje | 10490 | 3331 | ✅ |
| A2.04 | Buscar gastos (categoria) | busca meus gastos de transporte | 10493 | 3332 | ✅ |
| A2.05 | Editar valor gasto | o ifood foi 75, não 60. arruma | 10496 | 3333 | ✅ |
| A2.06 | Editar nome gasto | troca o nome ifood pra delivery | 10499 | 3334 | ✅ |
| A2.07 | Editar categoria gasto | muda delivery pra categoria alimentação | 10506 | 3335 | ✅ |
| A2.08 | Excluir gasto específico | tira o delivery | 10513 | 3336 | ✅ |
| A2.09 | Excluir último gasto | deleta o último lançamento | 10517 | 3337 | ⚠️ |
| A2.10 | Excluir múltiplos gastos | remove todos os gastos de gasolina | 10520 | 3338 | ⚠️ |
| A2.11 | Criar evento pontual | reunião com o chefe quarta às 10h | 10523 | 3339 | ✅ |
| A2.12 | Criar evento recorrente | corrida toda terça e quinta às 6h | 10526 | 3340 | ✅ |
| A2.13 | Buscar agenda dia | minha agenda de amanhã | 10529 | 3341 | ✅ |
| A2.14 | Buscar agenda semana | como tá minha semana? | 10532 | 3342 | ✅ |
| A2.15 | Editar horário evento | atrasa a reunião com o chefe pra 11h | 10535 | 3343 | ✅ |
| A2.16 | Editar data evento | empurra a reunião do chefe pra quinta | 10538 | 3344 | ✅ |
| A2.17 | Renomear evento | troca o nome da reunião pra alinhamento semanal | 10541 | 3345 | ✅ |
| A2.18 | Excluir evento | tira o alinhamento semanal | 10544 | 3346 | ⚠️ |
| A2.19 | Excluir evento recorrente | cancela a corrida de terça | 10547 | 3347 | ✅ |
| A2.20 | Excluir múltiplos eventos | apaga tudo de sexta | 10552 | 3348 | ✅ |
| A2.21 | Criar lembrete c/ horário | avisa pra eu ligar pro dentista às 18h | 10557 | 3349 | ✅ |
| A2.22 | Criar lembrete s/ horário | cria um lembrete de buscar encomenda | 10560 | 3350 | ✅ |
| A2.23 | Criar lembrete recorrente | me avisa toda segunda às 8h pra fazer relatório | 10563 | 3351 | ✅ |
| A2.24 | Consultar lembretes | lista meus lembretes | 10566 | 3352 | ✅ |
| A2.25 | Cancelar lembrete | tira o lembrete do dentista | 10569 | 3353 | ✅ |
| A2.26 | Cancelar lembrete recorrente | remove o lembrete do relatório | 10574 | 3354 | ✅ |
| A2.27 | Saudação | e aí beleza | 10579 | 3355 | ✅ |
| A2.28 | Fora do escopo | me conta uma piada | 10581 | 3356 | ✅ |
| A2.29 | Ação vs declaração | faz um pix de 80 pra Maria | 10583 | 3357 | ✅ |
| A2.30 | Investimento/poupança | investe 200 em bitcoin | 10585 | 3358 | ✅ |
| A2.31 | Planos/preços | quanto pago no premium? | 10587 | 3359 | ✅ |
| A2.32 | Erro digitação | qero ve mha agnda d hje | 10589 | 3360 | ✅ |
| A2.33 | Multi-turno | e amanhã? | 10592 | 3361 | ✅ |
| A2.34 | Emoji | 🤙 | 10595 | 3362 | ✅ |
| A2.35 | Verificar conexão Google | tô conectado no google agenda? | 10597 | 3363 | ✅ |
| A2.36 | Consultar eventos Google | puxa meus compromissos do google | 10599 | 3364 | ✅ |
| A2.37 | Conectar Google | quero conectar meu google | 10602 | 3365 | ✅ |
| A2.38 | Desconectar Google | desligar google calendar | 10604 | 3366 | ✅ |
| A2.39 | Relatório mensal | faz um resumo financeiro desse mês | 10606 | 3367 | ✅ |
| A2.40 | Relatório por período | relatório dos últimos 7 dias | 10609 | 3368 | ✅ |

### Passada A3 (40 testes: 38✅ 2⚠️ 0❌)

| ID | Ação | Input | exec_id | log_id | Status |
|---|------|-------|---------|--------|--------|
| A3.01 | Criar gasto | comprei um lanche por 25 reais | 10612 | 3371 | ✅ |
| A3.02 | Criar receita | entrou 800 de comissão | 10615 | 3372 | ✅ |
| A3.03 | Buscar gastos (período) | lista meus gastos da semana | 10618 | 3373 | ✅ |
| A3.04 | Buscar gastos (categoria) | quanto gastei com moradia? | 10621 | 3374 | ✅ |
| A3.05 | Editar valor gasto | o lanche custou 28, não 25 | 10624 | 3375 | ✅ |
| A3.06 | Editar nome gasto | renomeia lanche pra lanchonete | 10628 | 3376 | ✅ |
| A3.07 | Editar categoria gasto | muda lanchonete pra alimentação | 10632 | 3377 | ✅ |
| A3.08 | Excluir gasto específico | exclui lanchonete | 10636 | 3378 | ✅ |
| A3.09 | Excluir último gasto | apaga o último registro | 10640 | 3379 | ✅ |
| A3.10 | Excluir múltiplos gastos | deleta tudo de mercado | 10644 | 3380 | ⚠️ |
| A3.11 | Criar evento pontual | preciso ir no banco amanhã às 9h | 10646 | 3381 | ✅ |
| A3.12 | Criar evento recorrente | musculação toda segunda quarta e sexta 18h | 10649 | 3382 | ✅ |
| A3.13 | Buscar agenda dia | agenda do dia | 10652 | 3383 | ✅ |
| A3.14 | Buscar agenda semana | próximos 5 dias | 10655 | 3384 | ✅ |
| A3.15 | Editar horário evento | adianta o banco pra 8h | 10658 | 3385 | ✅ |
| A3.16 | Editar data evento | passa o banco pro dia 19 | 10661 | 3386 | ✅ |
| A3.17 | Renomear evento | muda banco pra resolver pendências | 10665 | 3387 | ✅ |
| A3.18 | Excluir evento | cancela resolver pendências | 10667 | 3388 | ⚠️ |
| A3.19 | Excluir evento recorrente | tira a musculação de quarta | 10667 | 3389 | ✅ |
| A3.20 | Excluir múltiplos eventos | limpa minha agenda de quinta | 10675 | 3390 | ✅ |
| A3.21 | Criar lembrete c/ horário | me avisa às 22h pra tomar remédio | 10678 | 3391 | ✅ |
| A3.22 | Criar lembrete s/ horário | lembrete de levar o cachorro no pet | 10681 | 3392 | ✅ |
| A3.23 | Criar lembrete recorrente | todo dia 15 me lembra de pagar internet | 10684 | 3393 | ✅ |
| A3.24 | Consultar lembretes | mostra meus próximos lembretes | 10687 | 3394 | ✅ |
| A3.25 | Cancelar lembrete | cancela lembrete do remédio | 10690 | 3395 | ✅ |
| A3.26 | Cancelar lembrete recorrente | tira o lembrete da internet | 10695 | 3396 | ✅ |
| A3.27 | Saudação | opa | 10698 | 3397 | ✅ |
| A3.28 | Fora do escopo | qual é a raiz quadrada de 144? | 10700 | 3398 | ✅ |
| A3.29 | Ação vs declaração | deposita 150 na minha conta | 10702 | 3399 | ✅ |
| A3.30 | Investimento/poupança | compra 3 bitcoins pra mim | 10704 | 3400 | ✅ |
| A3.31 | Planos/preços | como faço upgrade do plano? | 10706 | 3401 | ✅ |
| A3.32 | Erro digitação | qdos evntos tho amanh? | 10708 | 3402 | ✅ |
| A3.33 | Multi-turno | e depois de amanhã? | 10711 | 3403 | ✅ |
| A3.34 | Emoji | 🔥 | 10714 | 3404 | ✅ |
| A3.35 | Verificar conexão Google | meu calendar tá sincronizado? | 10716 | 3405 | ✅ |
| A3.36 | Consultar eventos Google | eventos do google amanhã | 10718 | 3406 | ✅ |
| A3.37 | Conectar Google | como conecto o google? | 10721 | 3407 | ✅ |
| A3.38 | Desconectar Google | tirar google agenda | 10723 | 3408 | ✅ |
| A3.39 | Relatório mensal | gera relatório mensal | 10725 | 3409 | ✅ |
| A3.40 | Relatório por período | relatório de fevereiro | 10728 | 3410 | ✅ |

### Passada A4 (40 testes: 37✅ 3⚠️ 0❌)

| ID | Ação | Input | exec_id | log_id | Status |
|---|------|-------|---------|--------|--------|
| A4.01 | Criar gasto | paguei 18 reais de estacionamento | 10731 | 3413 | ✅ |
| A4.02 | Criar receita | recebi 3500 do meu salário | 10734 | 3414 | ✅ |
| A4.03 | Buscar gastos (período) | meus gastos de março | 10737 | 3415 | ✅ |
| A4.04 | Buscar gastos (categoria) | gastos de saúde | 10740 | 3416 | ✅ |
| A4.05 | Editar valor gasto | estacionamento na verdade foi 22 | 10743 | 3417 | ✅ |
| A4.06 | Editar nome gasto | muda estacionamento pra parking | 10747 | 3418 | ✅ |
| A4.07 | Editar categoria gasto | coloca parking na categoria transporte | 10751 | 3419 | ✅ |
| A4.08 | Excluir gasto específico | deleta parking | 10755 | 3420 | ✅ |
| A4.09 | Excluir último gasto | remove meu último gasto registrado | 10759 | 3421 | ✅ |
| A4.10 | Excluir múltiplos gastos | apaga tudo que tem de luz | 10763 | 3422 | ⚠️ |
| A4.11 | Criar evento pontual | consulta médica dia 24 às 8h30 | 10766 | 3423 | ✅ |
| A4.12 | Criar evento recorrente | pilates terça e quinta 7h | 10769 | 3424 | ✅ |
| A4.13 | Buscar agenda dia | meus compromissos de hoje | 10772 | 3425 | ✅ |
| A4.14 | Buscar agenda semana | semana que vem | 10775 | 3426 | ✅ |
| A4.15 | Editar horário evento | atrasa a consulta médica meia hora | 10778 | 3427 | ✅ |
| A4.16 | Editar data evento | joga a consulta pro dia 25 | 10781 | 3428 | ✅ |
| A4.17 | Renomear evento | troca consulta médica pra check-up | 10784 | 3429 | ✅ |
| A4.18 | Excluir evento | remove check-up | 10787 | 3430 | ⚠️ |
| A4.19 | Excluir evento recorrente | exclui pilates de terça | 10790 | 3431 | ✅ |
| A4.20 | Excluir múltiplos eventos | cancela tudo do dia 25 | 10795 | 3432 | ✅ |
| A4.21 | Criar lembrete c/ horário | lembrete: reunião com banco 14h | 10821 | 3433 | ✅ |
| A4.22 | Criar lembrete s/ horário | me lembra de renovar CNH | 10824 | 3434 | ✅ |
| A4.23 | Criar lembrete recorrente | lembrete mensal dia 1 pra pagar condomínio | 10827 | 3435 | ✅ |
| A4.24 | Consultar lembretes | meus lembretes da semana | 10830 | 3436 | ✅ |
| A4.25 | Cancelar lembrete | cancela lembrete do banco | 10833 | 3437 | ✅ |
| A4.26 | Cancelar lembrete recorrente | tira o do condomínio | 10838 | 3438 | ⚠️ |
| A4.27 | Saudação | salve | 10841 | 3439 | ✅ |
| A4.28 | Fora do escopo | quantos habitantes tem a China? | 10843 | 3440 | ✅ |
| A4.29 | Ação vs declaração | paga a fatura do cartão de 450 | 10845 | 3441 | ✅ |
| A4.30 | Investimento/poupança | guarda 1000 na reserva de emergência | 10847 | 3442 | ✅ |
| A4.31 | Planos/preços | quero cancelar meu plano | 10850 | 3443 | ✅ |
| A4.32 | Erro digitação | qnto gstei n semana? | 10852 | 3444 | ✅ |
| A4.33 | Multi-turno | e na anterior? | 10855 | 3445 | ✅ |
| A4.34 | Emoji | 👋 | 10858 | 3446 | ✅ |
| A4.35 | Verificar conexão Google | google calendar conectado? | 10860 | 3447 | ✅ |
| A4.36 | Consultar eventos Google | agenda do google semana que vem | 10862 | 3448 | ✅ |
| A4.37 | Conectar Google | preciso conectar google | 10865 | 3449 | ✅ |
| A4.38 | Desconectar Google | remover google calendar | 10867 | 3450 | ✅ |
| A4.39 | Relatório mensal | relatório completo do mês | 10870 | 3451 | ✅ |
| A4.40 | Relatório por período | relatório de 10 a 16 de março | 10873 | 3452 | ✅ |

### Passada A5 (40 testes: 37✅ 3⚠️ 0❌)

| ID | Ação | Input | exec_id | log_id | Status |
|---|------|-------|---------|--------|--------|
| A5.01 | Criar gasto | desembolsei 95 numa janta | 10876 | 3453 | ✅ |
| A5.02 | Criar receita | caiu 4200 na conta do trabalho | 10879 | 3454 | ✅ |
| A5.03 | Buscar gastos (período) | total de gastos do mês | 10882 | 3455 | ✅ |
| A5.04 | Buscar gastos (categoria) | quanto torrei em outros? | 10885 | 3456 | ✅ |
| A5.05 | Editar valor gasto | a janta saiu 110, arruma pra mim | 10888 | 3457 | ✅ |
| A5.06 | Editar nome gasto | troca janta pra rodízio | 10892 | 3458 | ✅ |
| A5.07 | Editar categoria gasto | joga rodízio pra categoria lazer | 10896 | 3459 | ⚠️ |
| A5.08 | Excluir gasto específico | some com o rodízio | 10899 | 3460 | ✅ |
| A5.09 | Excluir último gasto | apaga o último que registrei | 10904 | 3461 | ✅ |
| A5.10 | Excluir múltiplos gastos | limpa todos os tesouro direto | 10908 | 3462 | ✅ |
| A5.11 | Criar evento pontual | oculista sexta que vem às 11h | 10910 | 3463 | ✅ |
| A5.12 | Criar evento recorrente | futebol todo sábado 16h | 10913 | 3464 | ✅ |
| A5.13 | Buscar agenda dia | agenda de hoje | 10916 | 3465 | ✅ |
| A5.14 | Buscar agenda semana | próxima semana inteira | 10919 | 3466 | ✅ |
| A5.15 | Editar horário evento | empurra oculista pra 11h30 | 10922 | 3467 | ✅ |
| A5.16 | Editar data evento | troca oculista pro dia 22 | 10925 | 3468 | ✅ |
| A5.33 | Multi-turno | e no sábado? | 10960 | 3469 | ✅ |
| A5.34 | Emoji | ✌️ | 10963 | 3470 | ✅ |
| A5.35 | Verificar conexão Google | sincronização com google ativa? | 10965 | 3471 | ✅ |
| A5.36 | Consultar eventos Google | meus eventos do google pro fim de semana | 10967 | 3472 | ✅ |
| A5.37 | Conectar Google | como faço pra ligar o google calendar? | 10970 | 3473 | ✅ |
| A5.38 | Desconectar Google | quero tirar meu google calendar | 10972 | 3474 | ✅ |
| A5.39 | Relatório mensal | relatório semanal | 10974 | 3475 | ✅ |
| A5.40 | Relatório por período | relatório personalizado de 01 a 15 de março | 10977 | 3476 | ✅ |
| A5.17 | Renomear evento | muda oculista pra oftalmologista | 10982 | 3480 | ✅ |
| A5.18 | Excluir evento | apaga oftalmologista | 10985 | 3481 | ⚠️ |
| A5.19 | Excluir evento recorrente | tira o futebol desse sábado | 10988 | 3482 | ⚠️ |
| A5.20 | Excluir múltiplos eventos | remove tudo do dia 28 | 10991 | 3483 | ✅ |
| A5.21 | Criar lembrete c/ horário | me avisa 19h pra fazer exercício | 10994 | 3484 | ✅ |
| A5.22 | Criar lembrete s/ horário | cria lembrete de pegar roupa na lavanderia | 10997 | 3485 | ✅ |
| A5.23 | Criar lembrete recorrente | todo dia 20 lembrete de pagar plano de saúde | 11000 | 3487 | ✅ |
| A5.24 | Consultar lembretes | quais são meus lembretes? | 11003 | 3488 | ✅ |
| A5.25 | Cancelar lembrete | apaga lembrete do exercício | 11006 | 3489 | ✅ |
| A5.26 | Cancelar lembrete recorrente | cancela o do plano de saúde | 11011 | 3491 | ✅ |
| A5.27 | Saudação | fala aí | 11014 | 3492 | ✅ |
| A5.28 | Fora do escopo | quem ganhou a copa de 2022? | 11016 | 3494 | ✅ |
| A5.29 | Ação vs declaração | transfere 500 pra conta poupança | 11018 | 3495 | ✅ |
| A5.30 | Investimento/poupança | aplica 2000 em CDB | 11020 | 3496 | ✅ |
| A5.31 | Planos/preços | informações sobre assinatura | 11022 | 3497 | ✅ |
| A5.32 | Erro digitação | qts evnts tho sext? | 11024 | 3498 | ✅ |

---

## Todos os Problemas Encontrados (15)

### Problema 1: A1.07 — muda a categoria do restaurante pra alimentação
- **Funcionalidade:** Editar categoria gasto
- **Execution ID n8n:** `10385`
- **Log ID Supabase:** `3295`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** ✏️ Não encontrei nenhum registro com esses dados. 

### Problema 2: A1.09 — apaga meu último gasto
- **Funcionalidade:** Excluir último gasto
- **Execution ID n8n:** `10391`
- **Log ID Supabase:** `3296`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Exclusão concluída!  📝 Registro: Almoço 💰 Valor: R$52 🗓️ Data: 17/03/2026  🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 3: A1.10 — apaga todos os gastos de uber
- **Funcionalidade:** Excluir múltiplos gastos
- **Execution ID n8n:** `10398`
- **Log ID Supabase:** `3297`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 4: A1.19 — cancela a academia de segunda
- **Funcionalidade:** Excluir evento recorrente
- **Execution ID n8n:** `10425`
- **Log ID Supabase:** `3306`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### Problema 5: A2.09 — deleta o último lançamento
- **Funcionalidade:** Excluir último gasto
- **Execution ID n8n:** `10517`
- **Log ID Supabase:** `3337`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 6: A2.10 — remove todos os gastos de gasolina
- **Funcionalidade:** Excluir múltiplos gastos
- **Execution ID n8n:** `10520`
- **Log ID Supabase:** `3338`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 7: A2.18 — tira o alinhamento semanal
- **Funcionalidade:** Excluir evento
- **Execution ID n8n:** `10544`
- **Log ID Supabase:** `3346`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### Problema 8: A3.10 — deleta tudo de mercado
- **Funcionalidade:** Excluir múltiplos gastos
- **Execution ID n8n:** `10644`
- **Log ID Supabase:** `3380`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 9: A3.18 — cancela resolver pendências
- **Funcionalidade:** Excluir evento
- **Execution ID n8n:** `10667`
- **Log ID Supabase:** `3388`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** Não encontrei nenhum evento chamado "Resolver Pendências" na sua agenda para os próximos dias. Posso ajudar com mais alguma coisa? 

### Problema 10: A4.10 — apaga tudo que tem de luz
- **Funcionalidade:** Excluir múltiplos gastos
- **Execution ID n8n:** `10763`
- **Log ID Supabase:** `3422`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 11: A4.18 — remove check-up
- **Funcionalidade:** Excluir evento
- **Execution ID n8n:** `10787`
- **Log ID Supabase:** `3430`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição. 

### Problema 12: A4.26 — tira o do condomínio
- **Funcionalidade:** Cancelar lembrete recorrente
- **Execution ID n8n:** `10838`
- **Log ID Supabase:** `3438`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum registro com essa descrição para condomínio. 

### Problema 13: A5.07 — joga rodízio pra categoria lazer
- **Funcionalidade:** Editar categoria gasto
- **Execution ID n8n:** `10896`
- **Log ID Supabase:** `3459`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** Parece que não encontrei nenhum registro com o nome 'Rodízio' como gasto no período consultado. Quer que eu registre algum gasto ou que eu verifique com outro nome ou data? 

### Problema 14: A5.18 — apaga oftalmologista
- **Funcionalidade:** Excluir evento
- **Execution ID n8n:** `10985`
- **Log ID Supabase:** `3481`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome ou a data aproximada. 

### Problema 15: A5.19 — tira o futebol desse sábado
- **Funcionalidade:** Excluir evento recorrente
- **Execution ID n8n:** `10988`
- **Log ID Supabase:** `3482`
- **Status:** ⚠️
- **Diagnóstico:** Não encontrou item
- **Resposta:** 🗑️ Não encontrei nenhum evento com esses critérios.  Me diga o nome completo do evento ou a data aproximada para eu localizar e excluir. 

---

## Confiabilidade por Funcionalidade

| # | Funcionalidade | A1 | A2 | A3 | A4 | A5 | Score | Status |
|---|---------------|----|----|----|----|-----|-------|--------|
| .01 | Criar gasto | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .02 | Criar receita | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .03 | Buscar gastos (período) | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .04 | Buscar gastos (categoria) | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .05 | Editar valor gasto | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .06 | Editar nome gasto | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .07 | Editar categoria gasto | ⚠️ | ✅ | ✅ | ✅ | ⚠️ | 3/5 | 🔴 Instável |
| .08 | Excluir gasto específico | — | ✅ | ✅ | ✅ | ✅ | 4/4 | 🟢 Estável |
| .09 | Excluir último gasto | ⚠️ | ⚠️ | ✅ | ✅ | ✅ | 3/5 | 🔴 Instável |
| .10 | Excluir múltiplos gastos | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ✅ | 1/5 | 🔴 Instável |
| .11 | Criar evento pontual | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .12 | Criar evento recorrente | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .13 | Buscar agenda dia | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .14 | Buscar agenda semana | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .15 | Editar horário evento | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .16 | Editar data evento | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .17 | Renomear evento | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .18 | Excluir evento | ✅ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | 1/5 | 🔴 Instável |
| .19 | Excluir evento recorrente | ⚠️ | ✅ | ✅ | ✅ | ⚠️ | 3/5 | 🔴 Instável |
| .20 | Excluir múltiplos eventos | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .21 | Criar lembrete c/ horário | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .22 | Criar lembrete s/ horário | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .23 | Criar lembrete recorrente | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .24 | Consultar lembretes | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .25 | Cancelar lembrete | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .26 | Cancelar lembrete recorrente | ✅ | ✅ | ✅ | ⚠️ | ✅ | 4/5 | 🟡 Quase |
| .27 | Saudação | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .28 | Fora do escopo | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .29 | Ação vs declaração | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .30 | Investimento/poupança | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .31 | Planos/preços | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .32 | Erro digitação | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .33 | Multi-turno | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .34 | Emoji | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .35 | Verificar conexão Google | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .36 | Consultar eventos Google | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .37 | Conectar Google | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .38 | Desconectar Google | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .39 | Relatório mensal | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |
| .40 | Relatório por período | ✅ | ✅ | ✅ | ✅ | ✅ | 5/5 | 🟢 Estável |