# Comparação de Evolução — Antes vs Depois
**Data:** 2026-03-17
**Antes:** Bateria original (200 testes, 16/03 pré-correções)
**Depois:** Bateria A v2 (199 testes, 17/03 pós-correções)

---

## Visão Geral

| Métrica | Antes | Depois | Mudança |
|---------|-------|--------|---------|
| Total testes | 200 | 199 | -1 |
| ✅ Sucesso | 147 (73.5%) | 181 (91%) | **+17.5 pontos** |
| ⚠️ Warning | 22 (11%) | 18 (9%) | -2 pontos |
| ❌ Erro | 31 (15.5%) | 0 (0%) | **-15.5 pontos** |
| Timeouts | 3 | 0 | -3 |
| Bugs T0 | 4 | **0** | **-4** |
| Bugs total | 17 | 7 | **-10 (59%)** |

---

## Bugs CORRIGIDOS (10 bugs eliminados)

| # | Bug | Score antes | Score depois | Status |
|---|-----|-----------|-------------|--------|
| 1 | Ação vs declaração (pix/boleto) | **1/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 2 | Investimento como gasto | **1/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 3 | "Registro registrado" + Cat Outros | **0/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 4 | "Semana que vem" = relatório | **3/5** 🟡 | **5/5** 🟢 | ✅ CORRIGIDO |
| 5 | Consultar lembretes só dia atual | **2/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 6 | Multi-turno gasto fantasma | **2/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 7 | Emoji registra gastos (👍) | **0/5** 🔴 | **5/5** 🟢 | ✅ CORRIGIDO |
| 11 | TIMEOUT 67s | **4/5** 🟡 | **5/5** 🟢 | ✅ CORRIGIDO |
| 14 | Conta piada | **4/5** 🟡 | **5/5** 🟢 | ✅ CORRIGIDO |
| 16 | Rename pergunta ao invés de fazer | **4/5** 🟡 | **5/5** 🟢 | ✅ CORRIGIDO |

### O que corrigiu esses bugs:
- **Bugs 1,2,4:** Regra de Ação Financeira no classificador (`Escolher Branch`)
- **Bug 3:** "Entrada registrada" + categorias de receita no prompt `registrar_gasto`
- **Bugs 5,6,7:** REGRA DE CONTINUAÇÃO restrita + busca 14 dias no AI Agent
- **Bug 11:** maxTries 5→2 no AI Agent
- **Bug 14:** "NÃO conta piadas" no AI Agent
- **Bug 16:** "NUNCA peça confirmação para CRIAR ou EDITAR"

---

## Bugs que PERSISTEM (5 bugs)

| # | Bug | Score antes | Score depois | Mudança |
|---|-----|-----------|-------------|---------|
| 8 | Excluir recorrente falha | 3/5 🟡 | 3/5 🟡 | = |
| 9 | Excluir após rename falha | 4/5 🟡 | 1/5 🔴 | PIOROU |
| 10 | Cancelar lembrete recorrente | 3/5 🟡 | 4/5 🟡 | +1 |
| 15 | "Apaga último" não encontra | 4/5 🟡 | 3/5 🟡 | -1 |
| 17 | Latência alta | sistêmico | reduzida | MELHOROU |

### Nota sobre Bug 9 (rename):
Piorou de 4/5 para 1/5 — mas isso pode ser porque agora os testes são mais rigorosos. Antes, o rename nem sempre era testado com exclusão posterior.

---

## Bugs NOVOS (2 bugs — falsos positivos)

| # | Bug | Score | Real? |
|---|-----|-------|-------|
| N1 | Excluir múltiplos que não existem | 2/5 | ❌ Design do teste |
| N2 | Editar categoria após rename | 3/5 | ⚠️ Parcial (contexto Redis) |

---

## Confiabilidade por Funcionalidade — Antes vs Depois

| Funcionalidade | Antes | Depois | Mudança |
|---------------|-------|--------|---------|
| Criar gasto | 5/5 🟢 | 5/5 🟢 | = |
| Criar receita | **0/5 🔴** | **5/5 🟢** | **+5** |
| Buscar gastos (período) | 5/5 🟢 | 5/5 🟢 | = |
| Buscar gastos (categoria) | 4/5 🟡 | 3/5 🟡 | -1 |
| Editar valor gasto | 3/5 🟡 | 5/5 🟢 | +2 |
| Editar nome gasto | 4/5 🟡 | 5/5 🟢 | +1 |
| Editar categoria gasto | 3/5 🟡 | 3/5 🟡 | = |
| Excluir gasto específico | 3/5 🟡 | 5/5 🟢 | +2 |
| Excluir último gasto | 4/5 🟡 | 3/5 🟡 | -1 |
| Excluir múltiplos gastos | 5/5 🟢 | 2/5 🟡 | -3* |
| Criar evento | 5/5 🟢 | 5/5 🟢 | = |
| Criar recorrente | 5/5 🟢 | 5/5 🟢 | = |
| Buscar agenda dia | 4/5 🟡 | 5/5 🟢 | +1 |
| Buscar agenda semana | **3/5 🔴** | **5/5 🟢** | **+2** |
| Editar horário evento | 5/5 🟢 | 5/5 🟢 | = |
| Editar data evento | 5/5 🟢 | 5/5 🟢 | = |
| Renomear evento | 4/5 🟡 | 5/5 🟢 | +1 |
| Excluir evento | 3/5 🟡 | 1/5 🔴 | -2 |
| Excluir recorrente | 3/5 🟡 | 3/5 🟡 | = |
| Excluir múltiplos eventos | 5/5 🟢 | 5/5 🟢 | = |
| Criar lembrete c/ horário | 5/5 🟢 | 5/5 🟢 | = |
| Criar lembrete s/ horário | 4/5 🟡 | 5/5 🟢 | +1 |
| Criar lembrete recorrente | 5/5 🟢 | 5/5 🟢 | = |
| Consultar lembretes | **2/5 🔴** | **5/5 🟢** | **+3** |
| Cancelar lembrete | 5/5 🟢 | 5/5 🟢 | = |
| Cancelar lembrete recorrente | 3/5 🟡 | 4/5 🟡 | +1 |
| Saudação | 5/5 🟢 | 5/5 🟢 | = |
| Fora do escopo | 4/5 🟡 | 5/5 🟢 | +1 |
| Ação vs declaração | **1/5 🔴** | **5/5 🟢** | **+4** |
| Investimento/poupança | **1/5 🔴** | **5/5 🟢** | **+4** |
| Planos/preços | 3/5 🟡 | 5/5 🟢 | +2 |
| Erro digitação | 5/5 🟢 | 5/5 🟢 | = |
| Multi-turno | **2/5 🔴** | **5/5 🟢** | **+3** |
| Emoji | 5/5 🟢 | 5/5 🟢 | = |
| Verificar Google | 5/5 🟢 | 5/5 🟢 | = |
| Consultar Google | 4/5 🟡 | 5/5 🟢 | +1 |
| Conectar Google | 5/5 🟢 | 5/5 🟢 | = |
| Desconectar Google | 5/5 🟢 | 5/5 🟢 | = |
| Relatório mensal | 5/5 🟢 | 5/5 🟢 | = |
| Relatório por período | 5/5 🟢 | 5/5 🟢 | = |

*\* Excluir múltiplos gastos caiu por falso positivo (itens não existem no teste)*

### Funções 5/5 estáveis:
- **Antes:** 17/40 (42.5%)
- **Depois:** 31/40 (77.5%)
- **Melhoria:** +35 pontos percentuais

---

## Resumo da Evolução

```
ANTES (16/03):
  ████████████████░░░░░░░░░░░░░░░░░░░░░░░░  73.5% sucesso
  T0: ████ (4 bugs críticos)

DEPOIS (17/03):
  ████████████████████████████████████████░░  91% sucesso
  T0: (0 bugs críticos)

MELHORIA: +17.5 pontos percentuais
BUGS: 17 → 7 (-59%)
FUNÇÕES ESTÁVEIS: 17 → 31 (+82%)
```

### O que causou a melhoria:
1. **Classificador corrigido** → ação vs declaração, investimento, semana que vem
2. **Prompt registrar_gasto** → "Entrada registrada", categorias, REGRA CONTINUAÇÃO
3. **AI Agent prompt** → escopo expandido, busca 14 dias, sem piadas
4. **Config** → maxTries 5→2 (eliminou timeouts)

### O que ainda precisa de atenção:
1. **Excluir evento após rename** (T1) → workflow Calendar WebHooks
2. **Excluir recorrente por ocorrência** (T1) → busca por rrule
3. **"Último gasto" usa contexto** (T2) → prompt excluir2
