# Relatório Final — 200 Testes de Confiabilidade
**Data:** 2026-03-16
**Metodologia:** 5 passadas x 40 ações, cada passada com frases diferentes
**Total:** 200 testes

---

## TABELA DE CONFIABILIDADE POR FUNCIONALIDADE

### FINANCEIRO (10 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 1 | Criar gasto | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 2 | Criar receita | ⚠️ | ⚠️ | ⚠️ | ⚠️ | ⚠️ | **0/5** | 🔴 "Registro registrado" + Cat Outros |
| 3 | Buscar gastos (período) | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 4 | Buscar gastos (categoria) | ✅ | ✅ | ✅ | ✅ | ⚠️ | **4/5** | 🟡 Lento em 1 caso (51s) |
| 5 | Editar valor de gasto | ✅ | ✅ | ⚠️ | ✅ | ❌ | **3/5** | 🟡 Instável |
| 6 | Editar nome de gasto | ❌ | ✅ | ✅ | ✅ | ✅ | **4/5** | 🟡 1x confundiu com evento |
| 7 | Editar categoria de gasto | ⚠️ | ✅ | ⚠️ | ✅ | ✅ | **3/5** | 🟡 Lento (27-45s) |
| 8 | Excluir gasto específico | ✅ | ✅ | ⚠️ | ❌ | ✅ | **3/5** | 🟡 1x confundiu com evento |
| 9 | Excluir último gasto | ✅ | ✅ | ✅ | ✅ | ❌ | **4/5** | 🟡 1x não encontrou |
| 10 | Excluir múltiplos gastos | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |

### AGENDA (10 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 11 | Criar evento pontual | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 12 | Criar evento recorrente | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 13 | Buscar agenda do dia | ❌ | ✅ | ✅ | ✅ | ✅ | **4/5** | 🟡 1x não encontrou |
| 14 | Buscar agenda da semana | ✅ | ✅ | ✅ | ❌ | ❌ | **3/5** | 🔴 2x confundiu com relatório |
| 15 | Editar horário de evento | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 16 | Editar data de evento | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 17 | Renomear evento | ✅ | ✅ | ⚠️ | ✅ | ✅ | **4/5** | 🟡 1x perguntou ao invés de fazer |
| 18 | Excluir evento específico | ✅ | ✅ | ⚠️ | ❌ | ✅ | **3/5** | 🟡 1x não encontrou após rename |
| 19 | Excluir evento recorrente | ❌ | ✅ | ✅ | ✅ | ❌ | **3/5** | 🟡 Inconsistente |
| 20 | Excluir múltiplos eventos | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |

### LEMBRETES (6 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 21 | Criar lembrete com horário | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 22 | Criar lembrete sem horário | ❌ | ✅ | ✅ | ✅ | ✅ | **4/5** | 🟡 1x TIMEOUT 67s |
| 23 | Criar lembrete recorrente | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 24 | Consultar lembretes | ⚠️ | ⚠️ | ✅ | ✅ | ⚠️ | **2/5** | 🔴 3x mostrou só dia atual |
| 25 | Cancelar lembrete | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 26 | Cancelar lembrete recorrente | ✅ | ✅ | ❌ | ❌ | ✅ | **3/5** | 🟡 2x não encontrou |

### CONVERSAÇÃO (8 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 27 | Saudação | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 28 | Fora do escopo | ✅ | ❌ | ✅ | ✅ | ✅ | **4/5** | 🟡 1x contou piada |
| 29 | Ação vs declaração | ❌ | ✅ | ❌ | ❌ | ❌ | **1/5** | 🔴 CRÍTICO |
| 30 | Investimento/poupança | ❌ | ❌ | ✅ | ❌ | ❌ | **1/5** | 🔴 CRÍTICO |
| 31 | Planos/preços | ❌ | ✅ | ✅ | ✅ | ⚠️ | **3/5** | 🟡 Inconsistente |
| 32 | Erro de digitação | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 33 | Contexto multi-turno | ⚠️ | ✅ | ✅ | ❌ | ⚠️ | **2/5** | 🔴 1x registrou gasto fantasma |
| 34 | Edge case (emoji) | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |

### GOOGLE CALENDAR (4 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 35 | Verificar conexão | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 36 | Consultar eventos Google | ✅ | ⚠️ | ✅ | ✅ | ✅ | **4/5** | 🟡 |
| 37 | Conectar Google | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 38 | Desconectar Google | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |

### RELATÓRIOS (2 ações)

| # | Ação | P1 | P2 | P3 | P4 | P5 | Score | Status |
|---|------|----|----|----|----|-----|-------|--------|
| 39 | Relatório mensal | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |
| 40 | Relatório por período | ✅ | ✅ | ✅ | ✅ | ✅ | **5/5** | 🟢 Estável |

---

## RANKING DE CONFIABILIDADE

### 🟢 100% Confiável (5/5) — 17 ações
1. Criar gasto
3. Buscar gastos por período
10. Excluir múltiplos gastos
11. Criar evento pontual
12. Criar evento recorrente
15. Editar horário de evento
16. Editar data de evento
20. Excluir múltiplos eventos
21. Criar lembrete com horário
23. Criar lembrete recorrente
25. Cancelar lembrete
27. Saudação
32. Erro de digitação
34. Emoji
35-38. Google Calendar (4 ações)
39-40. Relatórios (2 ações)

### 🟡 Parcialmente confiável (3-4/5) — 14 ações
4. Buscar gastos por categoria (4/5)
5. Editar valor de gasto (3/5)
6. Editar nome de gasto (4/5)
7. Editar categoria de gasto (3/5)
8. Excluir gasto específico (3/5)
9. Excluir último gasto (4/5)
13. Buscar agenda do dia (4/5)
17. Renomear evento (4/5)
18. Excluir evento específico (3/5)
19. Excluir evento recorrente (3/5)
22. Criar lembrete sem horário (4/5)
26. Cancelar lembrete recorrente (3/5)
28. Fora do escopo (4/5)
31. Planos/preços (3/5)

### 🔴 Não confiável (0-2/5) — 5 ações
2. Criar receita (0/5) — "Registro registrado" + Cat Outros SEMPRE
14. Buscar agenda da semana (3/5) — confunde com relatório
24. Consultar lembretes (2/5) — mostra só dia atual
29. Ação vs declaração (1/5) — registra como gasto
30. Investimento/poupança (1/5) — registra como gasto
33. Contexto multi-turno (2/5) — inconsistente

---

## ESTATÍSTICAS GERAIS

| Métrica | Valor |
|---------|-------|
| Total de testes | 200 |
| ✅ Sucesso | 147 (73.5%) |
| ⚠️ Parcial | 22 (11%) |
| ❌ Falha | 31 (15.5%) |
| Ações 100% confiáveis | 17/40 (42.5%) |
| Ações instáveis (≤2/5) | 5/40 (12.5%) |
| Latência média | ~9s |
| Latência máxima | 67s (timeout) |

### Progressão histórica:
```
Bateria 01 (15/03): 55% sucesso
Bateria 02 (15/03): 65% sucesso
Rodadas mistas (16/03): 69% sucesso
Teste final (16/03): 73.5% sucesso ← AGORA
```

---

## BUGS POR FREQUÊNCIA

| Bug | Ocorrências | Impacto |
|-----|-------------|---------|
| "Registro registrado" + Cat Outros para receitas | 5/5 (100%) | Médio — UX ruim |
| Ação registrada como gasto (pix/boleto/transferência) | 4/5 (80%) | ALTO — dados incorretos |
| Investimento registrado como gasto | 4/5 (80%) | ALTO — dados incorretos |
| Consulta de lembretes mostra só dia atual | 3/5 (60%) | Médio — informação incompleta |
| "Semana que vem" vira relatório financeiro | 2/5 (40%) | Médio — classificação errada |
| Excluir evento recorrente falha | 2/5 (40%) | Alto — funcionalidade quebrada |
| Cancelar lembrete recorrente "não encontrei" | 2/5 (40%) | Alto — funcionalidade quebrada |
| Confundir gasto com evento na edição/exclusão | 2/5 (40%) | Alto — operação errada |
| Multi-turno registra gasto fantasma | 1/5 (20%) | CRÍTICO — dados inventados |
| Contou piada (saiu do escopo) | 1/5 (20%) | Baixo |
| TIMEOUT 67s | 1/5 (20%) | Alto — UX |
| Editar valor criou novo gasto | 1/5 (20%) | Alto — duplicata |

---

## TOP 5 PRIORIDADES DE CORREÇÃO

### 1. Ação vs Declaração (1/5 confiável)
**O mais grave.** "Paga boleto", "faz pix", "transfere" são registrados como gastos.
**Fix:** Regra no prompt separando verbos de ação (imperativo) de declaração (passado).

### 2. Investimento/Poupança (1/5 confiável)
"Coloca na poupança", "investe em bitcoin" viram gastos.
**Fix:** Incluir no prompt que investimentos e transferências entre contas NÃO são gastos.

### 3. Receita sempre "Registro registrado" + Cat Outros (0/5)
Em 5 passadas, NUNCA acertou. Sempre redundante e sem categoria.
**Fix:** Trocar texto para "Entrada registrada" e categorizar salário/freelance como "Renda".

### 4. Consultar lembretes incompleto (2/5)
Mostra só o dia atual na maioria das vezes.
**Fix:** No prompt de busca, quando pedir "lembretes", buscar próximos 7-14 dias, não só hoje.

### 5. Contexto multi-turno (2/5)
"E na anterior?" registrou R$1500 de freelance como gasto novo.
**Fix:** Regra no prompt: "e na/no [período]?" é BUSCA, nunca REGISTRO.
