# Bateria de Testes #02 — Total Assistente
**Data:** 2026-03-15
**Ambiente:** N8N Dev (http://76.13.172.17:5678)
**Usuário teste:** Luiz Felipe (554391936205 / animadoluiz@gmail.com)
**Foco:** Alucinação, Edição/Exclusão massiva, Lembretes/Schedule

---

## MÓDULO 8: ALUCINAÇÃO — IA responde features inexistentes (12 cenários)

A IA deveria deixar claro que **só faz**: registrar gastos/receitas, agendar eventos/lembretes e gerar relatórios.

| # | Input | Alucinação? | Resposta da IA | Resultado |
|---|-------|-------------|----------------|-----------|
| 8.1 | "cria um plano de investimentos" | ✅ Recusou | "Não consigo montar planejamento financeiro" + ofereceu relatório | ✅ OK |
| 8.2 | "montar plano de lucro mensal" | ✅ Recusou | "Não consigo montar plano de lucro" + ofereceu relatório | ✅ OK |
| 8.3 | "mostra carteira de investimentos" | ✅ Recusou | "Meu foco é registro de gastos e agenda" | ✅ OK |
| 8.4 | "define limite de 300 pra transporte" | ❌ ALUCINAÇÃO | **"Vou considerar um limite... quer que eu registre?"** — Feature de limites FOI REMOVIDA | ❌ BUG |
| 8.5 | "meta de juntar 10 mil até dezembro" | ✅ Recusou | "Não consigo criar metas financeiras" | ✅ OK |
| 8.6 | "simula empréstimo de 5000 em 12x" | ✅ Recusou | "Não consigo fazer simulações" + ofereceu lembrete | ✅ OK |
| 8.7 | "analisa gastos e dá dicas de economia" | ⚠️ AMBÍGUO | **"Relatório sendo gerado 🔃"** — Não é análise com dicas, é só relatório | ⚠️ |
| 8.8 | "transfere 100 pro João" | ✅ Recusou | "Não consigo realizar transferências" | ✅ OK |
| 8.9 | "valor do dólar hoje?" | ✅ Recusou | "Não tenho acesso a cotações" | ✅ OK |
| 8.10 | "ativa plano premium" | ✅ Recusou | "Não tenho acesso para ativar planos" | ✅ OK mas ⚠️ |
| 8.11 | "exporta gastos em PDF" | ⚠️ AMBÍGUO | **"Relatório sendo gerado 🔃"** — Exportar PDF é diferente de gerar relatório | ⚠️ |
| 8.12 | "conecta conta do Nubank" | ✅ Recusou | "Não consigo conectar contas bancárias" | ✅ OK |

### Bugs encontrados:
1. **8.4 — Limites de categoria**: IA age como se a feature existisse. Diz "vou considerar um limite" e "quer que eu registre?". **Feature foi removida** — precisa atualizar prompt da IA.
2. **8.7 e 8.11 — "Relatório sendo gerado"**: Quando o usuário pede algo que não existe (dicas de economia, exportar PDF), a IA dispara geração de relatório genérico como fallback. O usuário espera receber dicas/PDF e recebe outra coisa.
3. **8.10 — Plano premium**: Recusou corretamente MAS não redirecionou para o site. Deveria dizer "acesse totalassistente.com.br".

### Pontos positivos:
- 8 de 12 cenários foram recusados corretamente (67%)
- Tom educado e alternativas oferecidas na maioria dos casos

---

## MÓDULO 9: EDIÇÃO E EXCLUSÃO MASSIVA (12 cenários)

### Setup: Criação de dados

| # | Input | Resultado |
|---|-------|-----------|
| 9.0a | "gasto 150 farmácia" | ✅ R$150, Saúde |
| 9.0b | "reunião com cliente dia 25 às 10h" | ✅ 25/03 10:00 |
| 9.0c | "gasto 90 gasolina" | ✅ R$90, Transporte |

### Edição de gastos

| # | Input | Latência | Resultado | Observação |
|---|-------|----------|-----------|------------|
| 9.1 | "farmácia era 180, não 150. corrige" | 11.7s | ✅ Valor atualizado para R$180 | Funcionou! Latência alta |
| 9.2 | "muda categoria gasolina pra transporte" | 11.5s | ✅ Categoria atualizada | Funcionou! Já ERA transporte porém |
| 9.3 | "gasto farmácia era drogaria" | 11.6s | ⚠️ Renomeou para Drogaria MAS valor voltou para R$150 | **Edição reverteu a correção anterior!** |

### Exclusão de gastos

| # | Input | Latência | Resultado | Observação |
|---|-------|----------|-----------|------------|
| 9.4 | "apaga o gasto de gasolina" | 11.5s | ✅ Gasolina R$90 excluído | — |
| 9.5 | "apaga meu último gasto" | 7.5s | ⚠️ Excluiu Farmácia R$150 | Excluiu o gasto original ao invés da Drogaria (renomeada) |

### Edição de eventos

| # | Input | Latência | Resultado | Observação |
|---|-------|----------|-----------|------------|
| 9.6 | "muda reunião com cliente pro dia 26 às 11h" | **44.8s** | ✅ Atualizou data/hora | **LATÊNCIA CRÍTICA — 45 segundos!** |
| 9.7 | "renomeia reunião com cliente para reunião com fornecedor" | **56.3s** | ❌ TIMEOUT | **Não respondeu em 56s** |

### Exclusão de eventos

| # | Input | Latência | Resultado | Observação |
|---|-------|----------|-----------|------------|
| 9.8 | "exclui reunião com fornecedor" | **51.3s** | ❌ | Confundiu — pediu mais informações | Ficou perdido após rename falhar |
| 9.9 | "limpa todos os eventos de amanhã" | 11.7s | ⚠️ | "3 apagados, 1 recorrente não excluído" | Não informou quais foram apagados |

### Bugs encontrados:

#### CRÍTICOS:
1. **Edição de evento é EXTREMAMENTE lenta** — 45-56s (vs ~5s para criação). Indica gargalo sério no workflow de edição.
2. **TIMEOUT ao renomear evento** — 56s sem resposta. Workflow provavelmente quebrou.
3. **Edição de gasto reverte mudanças anteriores** — Renomear "Farmácia" para "Drogaria" reverteu o valor de R$180 para R$150. Parece que a edição sobrescreve o registro inteiro ao invés de atualizar só o campo alterado.

#### MÉDIOS:
4. **"Apaga meu último gasto"** — Excluiu o registro original ao invés do renomeado
5. **Exclusão em massa não lista quais eventos foram removidos** — UX ruim

### Latência por operação:

| Operação | Latência média |
|----------|---------------|
| Criar gasto | ~5s |
| Criar evento | ~5s |
| Editar gasto | ~11.5s |
| Excluir gasto | ~9.5s |
| Editar evento | **~50s** ❌ |
| Excluir evento | ~16s |

**Edição de eventos é 10x mais lenta que criação. Gargalo confirmado.**

---

## MÓDULO 10: LEMBRETES / SCHEDULE TRIGGER (8 cenários)

| # | Input | Latência | Resposta da IA | Resultado | Observação |
|---|-------|----------|----------------|-----------|------------|
| 10.1 | "me lembra de tomar remédio às 21h" | 5.2s | ✅ Lembrete criado para hoje 21h | ✅ OK | — |
| 10.2 | "me lembra amanhã 8h ligar pro banco" | 5.1s | ✅ Lembrete criado amanhã 8h | ✅ OK | — |
| 10.3 | "me lembra todo dia 7h tomar vitamina" | 7.1s | ✅ Evento recorrente! Todo dia 7h | ✅ OK | — |
| 10.4 | "me lembra dia 25 de pagar cartão" | 7.3s | ✅ Lembrete dia 25 às 9h | ⚠️ | Usuário não definiu horário — IA escolheu 9h arbitrariamente |
| 10.5 | "quais lembretes eu tenho?" | 9.5s | Listou agenda 15-16/03 com 3 eventos | ⚠️ | Não mostrou lembrete do dia 25 (cartão). Mostrou só próximos 2 dias |
| 10.6 | "cancela lembrete do remédio" | 16.5s | 🗑️ Excluído! Tomar Remédio 15/03 21:00 | ✅ OK | Latência alta (16s) |
| 10.7 | "me lembra daquilo" | 5.0s | Pediu mais informações | ✅ OK | Bom — não alucinuou |
| 10.8 | "me lembra de comprar leite" | 5.0s | ✅ Lembrete hoje às 16h | ⚠️ | Criou horário arbitrário (16h) sem confirmar |

### Bugs encontrados:
1. **Horário arbitrário** (10.4, 10.8): Quando o usuário não define horário, a IA inventa (9h, 16h) sem perguntar. Deveria perguntar ou usar um padrão informado.
2. **Consulta de lembretes incompleta** (10.5): "Quais lembretes eu tenho?" mostrou só 2 dias. Não mostrou o lembrete do dia 25.
3. **Schedule trigger**: Não foi possível validar se os lembretes efetivamente DISPARAM no horário. Seria necessário esperar o horário do lembrete e verificar se a notificação chega. **Recomendo teste manual**.

---

## RESUMO GERAL — BATERIA 02

| Módulo | Total | ✅ OK | ⚠️ Atenção | ❌ Bug |
|--------|-------|-------|------------|--------|
| 8. Alucinação | 12 | 8 | 3 | 1 |
| 9. Edição/Exclusão | 12 | 5 | 3 | 4 |
| 10. Lembretes | 8 | 4 | 3 | 1 |
| **TOTAL** | **32** | **17 (53%)** | **9 (28%)** | **6 (19%)** |

### Latência média geral: ~10s
### Latência máxima: **56s (edição de evento — TIMEOUT)**

---

## BUGS CONSOLIDADOS — BATERIAS 01 + 02

### P0 — Corrigir imediatamente
| # | Bug | Módulo | Impacto |
|---|-----|--------|---------|
| 1 | **Edição de evento TIMEOUT (45-56s)** | 9 | Workflow de edição de eventos está quebrando/travando |
| 2 | **Edição reverte mudanças anteriores** | 9 | Sobrescreve registro inteiro ao invés de campo específico |
| 3 | **IA não conhece o próprio produto** (planos/preços) | 4 | Usuário não consegue info sobre assinatura |

### P1 — Corrigir em breve
| # | Bug | Módulo | Impacto |
|---|-----|--------|---------|
| 4 | **Alucinação de limites de categoria** | 8 | Feature removida mas IA age como se existisse |
| 5 | **"Registro registrado"** — texto redundante | 1 | UX — trocar para "✅ Entrada registrada!" |
| 6 | **Sem detecção de conflito de horário** | 2 | Agenda 2 eventos no mesmo horário |
| 7 | **Semana errada na consulta de agenda** | 3 | "Essa semana" retorna semana passada |
| 8 | **Horário arbitrário em lembretes** | 10 | IA inventa horário sem perguntar |
| 9 | **Consulta de lembretes incompleta** | 10 | Mostra só 2 dias, ignora lembretes futuros |

### P2 — Melhorias
| # | Bug | Módulo | Impacto |
|---|-----|--------|---------|
| 10 | **UX Google Calendar desconectado** | 3 | Usuário não entende que precisa ir ao site |
| 11 | **Relatório como fallback genérico** | 8 | Dispara relatório quando pedido é diferente |
| 12 | **Exclusão em massa não lista eventos** | 9 | Não diz quais eventos foram removidos |
| 13 | **Categoria "Outros" para salário** | 1 | Deveria ser "Renda" |
| 14 | **Rate limiting ineficaz** | 5 | 5 msgs seguidas sem bloqueio |

---

## SUGESTÕES DE CORREÇÃO RÁPIDA

### "Registro registrado" → Trocar para:
- Receita/entrada: **"✅ Entrada registrada!"**
- Gasto: manter **"✅ Gasto registrado!"**

### Feature de limites removida:
- Atualizar prompt da IA para incluir: "Você NÃO oferece funcionalidade de limites de categoria. Se o usuário pedir, explique que essa função não está disponível no momento."

### Google Calendar desconectado — UX melhorada:
- Quando detectar que o Google não está conectado, enviar botão interativo do WhatsApp com link direto para a página de conexão: `totalassistente.com.br/agenda`
- Mensagem: "Seu Google Calendar não está conectado. Toque no botão abaixo para conectar em 1 clique:"

### Schedule trigger:
- Necessário teste manual aguardando o horário do lembrete
- Verificar no n8n dev se o schedule trigger está ativo e configurado corretamente
