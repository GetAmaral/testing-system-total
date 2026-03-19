# Metodologia de Auditoria — Limites por Categoria

**Funcionalidade:** `financeiro/02-limites-categoria`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### O que é

Usuários podem definir limites de gasto por categoria (ex: "Alimentação: R$500/mês"). Quando um gasto é registrado e a soma da categoria no mês ultrapassa o limite, o sistema deve alertar o usuário.

### Caminho no sistema

```
DEFINIÇÃO DO LIMITE (Frontend):
  App (React) → Supabase PostgREST → INSERT/UPDATE category_limits

VERIFICAÇÃO DO LIMITE (WhatsApp / N8N):
  User registra gasto → Fix Conflito v2 → branch criar_gasto
    → AI Agent recebe dados via nó "infos" → campo "colocar_limite"
    → Se limite existe para a categoria do gasto:
      → Calcular soma da categoria no mês
      → Se soma > limite → incluir alerta na resposta
    → Registra gasto normalmente (workflow Financeiro - Total)
```

### Workflows envolvidos

| Workflow | ID | Papel |
|----------|----|-------|
| Fix Conflito v2 | `ImW2P52iyCS0bGbQ` | Recebe limite via nó `infos.colocar_limite` e passa ao AI Agent |
| Financeiro - Total | `NCVLUtTn656ACUGS` | CRUD na tabela `spent` (o gasto em si) |

### Nós relevantes no Fix Conflito v2

```
Aggregate3 ← WT-MT / WF-MF / WT-MF / WF-MT (estados do user)
  ↓
infos (set node)
  data: {{ Aggregate.item.json.data }}
  colocar_limite: {{ Aggregate3.item.json.limite }}   ← aqui entram os limites
  agora: {{ $now }}
  ↓
AI Agent → recebe colocar_limite no contexto → decide se alerta ou não
```

### Tabela: `category_limits`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| `id` | UUID | PK |
| `user_id` | UUID | FK auth.users |
| `category` | TEXT | Categoria (deve ser uma das 11 do `spent`) |
| `limit_amount` | NUMERIC | Valor do limite |
| `created_at` | TIMESTAMP | Criação |
| `updated_at` | TIMESTAMP | Última atualização |

### Estado atual do user de teste

**User de teste (Luiz Felipe) NÃO tem limites configurados.**
Para testar, será necessário:
1. Criar limites via INSERT direto no Supabase (já que definição é via frontend)
2. Testar se o sistema alerta ao ultrapassar
3. Limpar limites depois dos testes

### Dados existentes no banco (outros users)

```
Moradia:      R$380   (user bb2c8e4e)
Mercado:      R$5     (user bb2c8e4e)
Alimentacao:  R$80    (user bb2c8e4e)
Lazer:        R$300   (user 1bf0892e)
Saude:        R$100   (user 1bf0892e)
Alimentacao:  R$500   (user 56e04928)
```

---

## 2. Endpoints de verificação

### Supabase Principal (service_role)

| Verificação | Query |
|-------------|-------|
| Limites do user | `GET /category_limits?select=*&user_id=eq.{user_id}` |
| Criar limite (setup) | `POST /category_limits` body: `{"user_id":"{id}","category":"{cat}","limit_amount":{val}}` |
| Deletar limite (cleanup) | `DELETE /category_limits?id=eq.{limit_id}` |
| Soma da categoria no mês | `GET /spent?select=value_spent&fk_user=eq.{user_id}&category_spent=eq.{cat}&transaction_type=eq.saida&date_spent=gte.{inicio_mes}` |

### Mesmos endpoints de `01-despesas-receitas` para spent, log_users_messages e N8N API.

---

## 3. Algoritmo de execução

### SETUP obrigatório (antes dos testes)

```
SETUP-1  Verificar limites existentes do user de teste
           GET /category_limits?user_id=eq.{user_id}
           → salvar: LIMITES_ANTES (deve ser vazio)

SETUP-2  Criar limite de teste
           POST /category_limits
           body: {"user_id":"2eb4065b-...","category":"Alimentacao","limit_amount":100}
           → salvar: LIMITE_ID

SETUP-3  Verificar que foi criado
           GET /category_limits?id=eq.{LIMITE_ID}
           → deve existir com limit_amount=100
```

### Para cada teste individual

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Contar gastos de Alimentação do mês
         GET /spent?fk_user=eq.{user_id}&category_spent=eq.Alimentacao
         &transaction_type=eq.saida&date_spent=gte.{inicio_mes}
         → salvar: SOMA_ANTES (SUM value_spent)
  1.2  Buscar último log_id → salvar: LAST_LOG_ID
  1.3  Calcular: MARGEM = 100 - SOMA_ANTES

PASSO 2 — ENVIAR MENSAGEM
  2.1  Mandar gasto que ultrapassa (ou não) o limite
  2.2  POST webhook dev

PASSO 3 — POLLAR RESPOSTA
  (mesmo algoritmo de 01-despesas-receitas)

PASSO 4 — VERIFICAR RESPOSTA DA IA
  4.1  Se SOMA_ANTES + valor_gasto > limite:
       → IA DEVERIA alertar sobre ultrapassagem do limite
  4.2  Se SOMA_ANTES + valor_gasto <= limite:
       → IA pode ou não mencionar o limite (registrar comportamento)

PASSO 5 — VERIFICAR BANCO
  5.1  Gasto foi criado no spent? (mesma verificação de 01)
  5.2  Soma nova da categoria = SOMA_ANTES + valor_gasto?
  5.3  Limite não foi alterado (category_limits intacto)

PASSO 6 — REGISTRAR

CLEANUP — Após todos os testes
  Deletar limites criados: DELETE /category_limits?id=eq.{LIMITE_ID}
  Deletar gastos criados: DELETE /spent?id_spent=eq.{ids_criados}
```

---

## 4. Critérios de PASS/FAIL

### Alerta de ultrapassagem

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Gasto abaixo do limite | Registra normalmente, sem alerta obrigatório | — |
| 2 | Gasto ultrapassa limite | Registra E inclui alerta na resposta | Registra sem alertar |
| 3 | Gasto cria registro | spent: +1 (independente do limite) | Não criou |
| 4 | Limite intacto | category_limits não foi alterado pelo gasto | Limite sumiu ou mudou |

### Limites no banco

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Limite criado corretamente | category_limits: category={cat}, limit_amount={val} | Não criou |
| 2 | Category válida | Uma das 11 categorias do spent | Inventada |
| 3 | User correto | user_id = user de teste | Outro |

---

## 5. Protocolo de diagnóstico de erros

> **QUANDO USAR:** Sempre que um teste retornar FAIL ou PARTIAL. O agente DEVE executar este protocolo ANTES de registrar o resultado final.

### Passo D1 — Identificar o ponto de falha

```
PERGUNTA: Em qual camada o erro aconteceu?

CAMADA 1 — CLASSIFICADOR (Escolher Branch)
  Verificar: A mensagem foi pro branch certo?
  Como: GET /executions/{exec_id} → ver qual output do Switch - Branches1 foi ativado
  Se erro aqui: branch errada → classificador não entendeu a intenção

CAMADA 2 — AI AGENT (prompt + raciocínio)
  Verificar: O AI Agent chamou as tools corretas?
  Como: No execution detail, ver quais tools foram invocadas
  Se erro aqui: agent não chamou buscar_financeiro ou chamou tool errada

CAMADA 3 — TOOL HTTP (chamada ao Financeiro - Total)
  Verificar: O webhook retornou sucesso?
  Como: GET /executions?workflowId=NCVLUtTn656ACUGS&limit=3 → ver últimas do Financeiro
  Se erro aqui: webhook falhou, timeout, parâmetros errados

CAMADA 4 — SUPABASE (operação no banco)
  Verificar: O INSERT/UPDATE/DELETE executou?
  Como: Comparar COUNT_ANTES vs COUNT_DEPOIS
  Se erro aqui: RLS bloqueou, constraint violada, dados inválidos

CAMADA 5 — RESPOSTA (formatação da mensagem)
  Verificar: A IA respondeu com formato correto?
  Como: Analisar ai_message no log
  Se erro aqui: JSON malformado, emoji errado, dados incorretos na mensagem
```

### Passo D2 — Coletar evidências

```
Para a camada identificada, coletar:

1. EXECUÇÃO N8N
   GET /executions/{exec_id}
   → Salvar: status, startedAt, stoppedAt, data (input/output de cada nó)

2. LOGS DO BANCO
   GET /log_users_messages?id=eq.{log_id}
   → Salvar: user_message, ai_message completos

3. ESTADO DO BANCO
   GET /spent?fk_user=eq.{user_id}&order=created_at.desc&limit=5
   GET /category_limits?user_id=eq.{user_id}
   → Salvar: estado atual completo

4. EXECUÇÕES SECUNDÁRIAS (se a tool chamou outro workflow)
   GET /executions?workflowId=NCVLUtTn656ACUGS&limit=3
   → Salvar: status e erros do workflow Financeiro
```

### Passo D3 — Classificar a causa raiz

```
CATEGORIAS DE CAUSA:

CLASSIFICAÇÃO_ERRADA
  → Branch errada no Switch - Branches1
  → Causa: prompt do Escolher Branch não cobriu o cenário
  → Recomendação: ajustar prompt do classificador

TOOL_NAO_CHAMADA
  → AI Agent não invocou a tool necessária
  → Causa: prompt do agent não instruiu corretamente
  → Recomendação: ajustar prompt do branch

TOOL_FALHOU
  → Tool HTTP retornou erro
  → Causa: webhook do Financeiro falhou, parâmetros errados
  → Recomendação: verificar workflow Financeiro - Total

BANCO_REJEITOU
  → Supabase retornou erro
  → Causa: RLS, constraint, tipo inválido
  → Recomendação: verificar policies e schema

RESPOSTA_ERRADA
  → Banco está correto mas IA respondeu errado
  → Causa: formatação do JSON de resposta, lógica do prompt
  → Recomendação: ajustar prompt de formatação

ASYNC_INCOMPLETO
  → Banco ainda não atualizou quando verificamos
  → Causa: delay normal do sistema
  → Ação: re-verificar após mais tempo. Se resolver, classificar como PASS_DELAYED

COMPORTAMENTO_NAO_DOCUMENTADO
  → Sistema fez algo que não está definido como certo ou errado
  → Ação: documentar comportamento observado para decisão do PO
```

### Passo D4 — Gerar relatório de diagnóstico

```markdown
### Diagnóstico: {TEST_ID}

**Veredicto original:** FAIL
**Camada do erro:** {1-5}
**Causa raiz:** {categoria}

**Evidências:**
- N8N exec: {exec_id} status={status}
- Branch escolhida: {branch}
- Tools chamadas: {lista}
- Log IA: "{ai_message truncada}"
- Banco antes: {estado}
- Banco depois: {estado}

**O que deveria ter acontecido:**
{descrição}

**O que aconteceu:**
{descrição}

**Recomendação:**
{ação sugerida para corrigir}
```

---

## 6. Testes — Nível 🟢 Quick (3 testes)

**Pré-requisito:** Criar limite Alimentacao=R$100 via INSERT direto.

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| LIM-Q1 | "gastei 30 no almoço" | Abaixo do limite (30 < 100) | spent: criou. IA: sem alerta obrigatório |
| LIM-Q2 | "gastei 80 na janta" | Ultrapassa (30+80=110 > 100) | spent: criou. IA: DEVE alertar ultrapassagem |
| LIM-Q3 | "quanto gastei de alimentação?" | Busca com limite | IA: mostra gastos. Verificar se menciona limite |

**Dependência:** Q1 → Q2 (Q2 depende da soma de Q1)

---

## 7. Testes — Nível 🟡 Broad (Quick + 7 testes)

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| LIM-B1 | (criar limite Transporte=R$200) + "gastei 50 de uber" | Categoria com limite novo | Alerta? Gasto criado? |
| LIM-B2 | "gastei 150 de uber" | Ultrapassa Transporte (50+150=200, exato no limite) | Alerta ou não? Documentar threshold (>= ou >) |
| LIM-B3 | "gastei 100 no cinema" | Categoria SEM limite (Lazer) | Registra normalmente, sem menção a limite |
| LIM-B4 | "gastei 10 de remédio" | Categoria com limite (se existir) vs sem | Comportamento consistente |
| LIM-B5 | Verificar soma real | SELECT SUM(value_spent) vs o que IA calcula | Totais batem? |
| LIM-B6 | Gasto do mês anterior | Limite é mensal — gastos antigos não contam | Soma só do mês atual |
| LIM-B7 | Deletar gasto que ultrapassava | Após excluir, soma volta abaixo | Estado correto |

---

## 8. Testes — Nível 🔴 Complete (Broad + 5 testes)

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| LIM-C1 | Limite de R$0 | Edge: limite zero | Qualquer gasto ultrapassa? |
| LIM-C2 | Limite muito alto (R$999999) | Nunca ultrapassa | Sistema não alerta |
| LIM-C3 | Múltiplos limites (3 categorias) | Gastar em cada uma | Cada categoria tem cálculo independente |
| LIM-C4 | Receita na mesma categoria | "recebi 500 de alimentação" | Entrada NÃO conta como gasto pro limite |
| LIM-C5 | Virada do mês | Gastos do mês anterior não afetam limite do mês atual | Reset correto |

---

## 9. Formato do log

Mesmo formato de `01-despesas-receitas`, acrescido de:

```markdown
### Contexto de limites

| Categoria | Limite | Soma antes | Soma depois | Ultrapassou? | IA alertou? |
|-----------|--------|------------|-------------|--------------|-------------|
| Alimentacao | R$100 | R$30 | R$110 | SIM | {SIM/NAO} |
```

---

## 10. Problemas conhecidos

| Problema | Impacto | Como lidar |
|----------|---------|------------|
| User de teste não tem limites | Precisa criar via INSERT direto | SETUP obrigatório antes dos testes |
| Limites são definidos via frontend | Watson não testa o frontend, só o efeito no WhatsApp | Criar limites manualmente |
| `colocar_limite` vem de Aggregate3 | Se o pipeline de dados falhar, limite chega vazio ao Agent | Verificar se infos.colocar_limite != null |
| Alerta é decisão do AI Agent | Não é lógica determinística — o Agent decide se menciona | Pode variar entre execuções |

---

## 11. Melhorias sugeridas

| O que | Impacto | Onde |
|-------|---------|------|
| Logar se limite foi verificado | Saber se o Agent recebeu o limite | Adicionar log no nó `infos` quando `colocar_limite` != null |
| Tornar alerta determinístico | Hoje o Agent decide se alerta. Deveria ser regra fixa | Adicionar IF no workflow: se soma > limite → mensagem fixa de alerta |
| Endpoint de limites via WhatsApp | User não pode definir/consultar limites pelo bot | Criar branch "definir_limite" no classificador |
