# Metodologia de Auditoria — Despesas e Receitas (CRUD Financeiro)

**Funcionalidade:** `financeiro/01-despesas-receitas`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho da mensagem

```
WhatsApp → Main (webhook trigger)
  → Verifica user (profiles)
  → Se Premium → Fix Conflito v2 (webhook /premium)
    → Escolher Branch (classificador LLM)
      → Branch: criar_gasto | buscar | editar | excluir
        → Seta prompt específico
        → AI Agent (GPT-4.1-mini) processa
          → Chama tool HTTP → Financeiro - Total (webhook)
            → /registrar-gasto  → INSERT spent
            → /filtros-supabase → SELECT spent
            → /editar-supabase  → GET + UPDATE spent
            → /excluir-supabase → GET + DELETE spent
          → Responde JSON → Formata mensagem
        → Envia WhatsApp
        → Loga em log_users_messages
```

### Workflows envolvidos

| Workflow | ID | Papel |
|----------|----|-------|
| Main - Total Assistente | `hLwhn94JSHonwHzl` | Recebe webhook, roteia por plano |
| Fix Conflito v2 | `ImW2P52iyCS0bGbQ` | Classificador + AI Agent + tools |
| Financeiro - Total | `NCVLUtTn656ACUGS` | CRUD real na tabela `spent` |

### Tabela: `spent`

| Campo | Tipo | Descrição | Valores válidos |
|-------|------|-----------|-----------------|
| `id_spent` | UUID | PK, auto-generated | — |
| `name_spent` | TEXT | Nome da transação | Livre |
| `value_spent` | NUMERIC | Valor | > 0 |
| `category_spent` | TEXT | Categoria | Alimentacao, Mercado, Moradia, Transporte, Saude, Educacao, Vestuario, Investimentos, Lazer, Tecnologia, Outros |
| `type_spent` | TEXT | Classificação | fixo, variavel, eventuais, emergencias, outros |
| `transaction_type` | TEXT | Direção | "saida" (gasto) ou "entrada" (receita) |
| `date_spent` | TIMESTAMP | Data da transação | — |
| `created_at` | TIMESTAMP | Data de criação | Auto |
| `fk_user` | UUID | FK para auth.users | — |

### Classificador — Branches financeiros

| Intenção do user | Branch esperada | Prompt ativado |
|------------------|-----------------|----------------|
| "gastei 45 no almoço" | `criar_gasto` | `registrar_gasto` |
| "recebi 2000 de salário" | `criar_gasto` | `registrar_gasto` |
| "quanto gastei hoje?" | `buscar` | `buscar_gasto` |
| "mostra gastos de alimentação" | `buscar` | `buscar_gasto` |
| "a pizza foi 55, não 47" | `editar` | `editar_gasto` |
| "muda pizza pra pizzaria" | `editar` | `editar_gasto` |
| "apaga o gasto da pizza" | `excluir` | `excluir2` |
| "paga meu boleto de 200" | `padrao` | (recusa) |
| "investe 2000 em CDB" | `padrao` | (recusa) |

### Regras do prompt registrar_gasto

- **REGRA ZERO:** Se tem valor + verbo de declaração (gastei, paguei, comprei, recebi, desembolsei, torrei, saiu, deu, custou, foi) → registrar imediatamente, sem perguntar.
- **EXCEÇÃO:** Verbo imperativo pedindo execução (paga, transfere, deposita, investe, aplica, faz pix) → NÃO registrar. Recusar.
- **REGRA DE CONTINUAÇÃO:** Se mensagem é confirmação ("sim", "ok") e histórico tem valor → extrair do histórico.

### Comportamento async

Edições e exclusões seguem o padrão:
1. IA anuncia ao user ("✅ Edição concluída!")
2. Tool HTTP é chamada para o workflow Financeiro
3. Workflow Financeiro executa no Supabase
4. Pode haver delay de 5-20s entre anúncio e execução real

**Implicação para testes:** Após resposta da IA para edição/exclusão, aguardar 20s antes de verificar o banco.

---

## 2. Endpoints de verificação

### Supabase Principal (service_role)

```
BASE: https://ldbdtakddxznfridsarn.supabase.co/rest/v1
HEADERS:
  apikey: {SERVICE_ROLE_KEY}
  Authorization: Bearer {SERVICE_ROLE_KEY}
```

| Verificação | Query |
|-------------|-------|
| Buscar por nome | `GET /spent?name_spent=ilike.*{nome}*&fk_user=eq.{user_id}&order=created_at.desc&limit=1` |
| Contar total | `GET /spent?select=id_spent&fk_user=eq.{user_id}` + `Prefer: count=exact` → ler header `content-range` |
| Criados hoje | `GET /spent?fk_user=eq.{user_id}&created_at=gte.{hoje}T00:00:00&order=created_at.desc` |
| Por ID | `GET /spent?select=*&id_spent=eq.{id}` |

### Supabase AI Messages (service_role)

```
BASE: https://hkzgttizcfklxfafkzfl.supabase.co/rest/v1
```

| Verificação | Query |
|-------------|-------|
| Último log | `GET /log_users_messages?select=*&user_phone=eq.554391936205&order=id.desc&limit=1` |
| Logs após ID | `GET /log_users_messages?select=*&user_phone=eq.554391936205&id=gt.{last_id}&order=id.asc` |

### N8N API

```
BASE: http://76.13.172.17:5678/api/v1
HEADER: X-N8N-API-KEY: {KEY}
```

| Verificação | Query |
|-------------|-------|
| Últimas execuções | `GET /executions?limit=5` |
| Execução por ID | `GET /executions/{exec_id}` |

### Webhook dev

```
POST http://76.13.172.17:5678/webhook/dev-whatsapp
Content-Type: application/json
```

### User de teste

```yaml
user_id: 2eb4065b-280c-4a50-8b54-4f9329bda0ff
phone: 554391936205
name: Luiz Felipe
email: animadoluiz@gmail.com
```

---

## 3. Algoritmo de execução

### Para cada teste individual:

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Contar registros: GET /spent?select=id_spent&fk_user=eq.{user_id}
       → salvar: COUNT_ANTES
  1.2  Se edição/exclusão: buscar registro alvo por nome
       → salvar: REGISTRO_ANTES (todos os campos)
  1.3  Buscar último log_id: GET /log_users_messages?order=id.desc&limit=1
       → salvar: LAST_LOG_ID
  1.4  Registrar timestamp UTC
       → salvar: TS_ANTES

PASSO 2 — ENVIAR MENSAGEM
  2.1  Montar payload WhatsApp com user de teste
  2.2  POST webhook dev
  2.3  Verificar HTTP 200 + body contém "Workflow was started"

PASSO 3 — POLLAR RESPOSTA DA IA
  3.1  Loop (max 45s, intervalo 3s):
         GET /log_users_messages?user_phone=eq.554391936205&id=gt.{LAST_LOG_ID}
         Se encontrou → salvar: LOG_RESPONSE (id, user_message, ai_message, created_at)
         Se não → sleep 3s, continuar
  3.2  Se timeout → marcar TIMEOUT, registrar, pular para PASSO 7

PASSO 4 — ESPERAR ASYNC (apenas edição/exclusão)
  4.1  Após capturar LOG_RESPONSE, sleep 20s
  4.2  Para criação e busca: pular este passo

PASSO 5 — VERIFICAR BANCO
  5.1  Contar registros → salvar: COUNT_DEPOIS
  5.2  Buscar registro por nome ou ID → salvar: REGISTRO_DEPOIS
  5.3  Cruzar:
       - CREATE: COUNT_DEPOIS = COUNT_ANTES + 1?
       - EDIT:   COUNT_DEPOIS = COUNT_ANTES? Campo editado mudou?
       - DELETE: COUNT_DEPOIS = COUNT_ANTES - 1?
       - READ:   Registros da IA existem no banco? Totais batem?
  5.4  Cruzar CADA campo do REGISTRO_DEPOIS com o que a IA disse:
       - name_spent vs nome na mensagem da IA
       - value_spent vs valor na mensagem da IA
       - category_spent vs categoria na mensagem da IA
       - transaction_type correto (saida/entrada)
       - type_spent é um dos 5 válidos
       - date_spent = dia do teste
       - fk_user = user_id de teste

PASSO 6 — VERIFICAR N8N (nível Complete)
  6.1  GET /executions?limit=5
  6.2  Identificar execução por timestamp (±10s do envio)
  6.3  Verificar status = "success"

PASSO 7 — REGISTRAR RESULTADO
  7.1  Classificar: PASS / FAIL / PARTIAL / TIMEOUT
  7.2  Registrar no log padronizado (seção 8)
```

---

## 4. Critérios de PASS/FAIL

### CRIAR gasto/receita

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Resposta da IA | Contém "✅ Gasto registrado" ou "✅ Entrada registrada" | Qualquer outro |
| 2 | Contagem | COUNT_DEPOIS = COUNT_ANTES + 1 | Diferença ≠ 1 |
| 3 | name_spent | Coerente com input (pode capitalizar/normalizar) | Completamente diferente |
| 4 | value_spent | Igual ao valor na mensagem | Diferente |
| 5 | category_spent | Um dos 11 válidos | Vazio ou inventado |
| 6 | transaction_type | "saida" se gasto, "entrada" se receita | Invertido |
| 7 | type_spent | Um dos 5 válidos | Inventado |
| 8 | date_spent | Mesmo dia do envio | Data errada |
| 9 | fk_user | = user_id de teste | Outro user |
| 10 | Category match IA | category que IA disse = category no banco | Divergente → registrar como PARTIAL |

### EDITAR gasto

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Resposta da IA | Contém "✅ Edição concluída" | Outro |
| 2 | Contagem | COUNT_DEPOIS = COUNT_ANTES | Criou duplicata ou deletou |
| 3 | Campo editado | Mudou para novo valor | Não mudou |
| 4 | Outros campos | Permanecem iguais ao ANTES | Regressão |

### EXCLUIR gasto

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Resposta da IA | Contém "🗑️ Exclusão concluída" | Outro |
| 2 | Contagem | COUNT_DEPOIS = COUNT_ANTES - 1 | Não mudou ou removeu mais |
| 3 | Registro | Busca pelo nome/ID retorna vazio | Ainda existe |

### BUSCAR gastos

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Resposta da IA | Contém "✅ Busca completa" | Erro |
| 2 | Registros existem | Cada registro citado pela IA existe no banco | IA inventou registro |
| 3 | Totais | Soma da IA = soma real no banco (para o mesmo filtro) | Divergente |
| 4 | Período | Registros dentro do range pedido | Fora do range |

### CLASSIFICAÇÃO (branch)

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Declaração → criar_gasto | "gastei", "paguei", "comprei" → cria registro | Não criou |
| 2 | Imperativo → padrao | "paga", "transfere", "investe" → NÃO cria | Criou |
| 3 | Recusa com mensagem | Texto menciona "não consigo executar transações" | Registrou sem avisar |

---

## 5. Testes — Nível 🟢 Quick (5 testes)

> Smoke test. Se qualquer um falhar, o sistema tem problema grave.

| ID | Operação | Input | Output esperado | Verificação banco |
|----|----------|-------|-----------------|-------------------|
| FIN-Q1 | Criar gasto | "gastei 35 no almoço" | "✅ Gasto registrado! Almoço R$35 Alimentação" | spent: +1, name=Almoço, value=35, type=saida |
| FIN-Q2 | Criar receita | "recebi 500 de freelance" | "✅ Entrada registrada! Freelance R$500" | spent: +1, name=Freelance, value=500, type=entrada |
| FIN-Q3 | Buscar período | "quanto gastei hoje?" | "✅ Busca completa! ..." | Registros citados existem no banco |
| FIN-Q4 | Editar valor | "o almoço foi 42, não 35" | "✅ Edição concluída! R$42" | spent: value_spent=42 (esperar 20s) |
| FIN-Q5 | Excluir gasto | "apaga o almoço" | "🗑️ Exclusão concluída!" | spent: -1, busca Almoço=vazio (esperar 20s) |

**Dependência:** Q1 → Q3 (Q3 busca o que Q1 criou). Q1 → Q4 → Q5 (edita e deleta o mesmo registro).
**Ordem:** Q1 → Q2 → Q3 → Q4 → (wait 20s) → Q5 → (wait 20s) → verificação final

---

## 6. Testes — Nível 🟡 Broad (Quick + 10 testes)

| ID | Operação | Input | O que valida |
|----|----------|-------|--------------|
| FIN-B1 | Criar com gíria | "torrei 60 conto no bar" | Classificador entende gíria → criar_gasto |
| FIN-B2 | Receita informal | "caiu 3000 na conta" | transaction_type=entrada, category coerente |
| FIN-B3 | Editar nome | "muda almoço pra restaurante" | name_spent mudou, value_spent intacto |
| FIN-B4 | Editar categoria | "coloca restaurante em lazer" | category_spent mudou, outros campos intactos |
| FIN-B5 | Buscar por categoria | "gastos de alimentação" | IA filtra correto → cruzar com banco |
| FIN-B6 | Excluir último | "apaga meu último gasto" | O mais recente (by created_at) removido |
| FIN-B7 | Excluir múltiplos | "remove todos de uber" | Todos com name LIKE uber removidos |
| FIN-B8 | Ação vs declaração | "paga meu boleto de 200" | NÃO cria. Branch=padrao. Mensagem de recusa |
| FIN-B9 | Investimento | "aplica 2000 em CDB" | NÃO cria. Branch=padrao. Mensagem de recusa |
| FIN-B10 | Valor centavos | "gastei 29.90 de gasolina" | value_spent=29.90 (não arredondado) |

---

## 7. Testes — Nível 🔴 Complete (Broad + 15 testes)

| ID | Operação | Input | O que valida |
|----|----------|-------|--------------|
| FIN-C1 | Sem valor | "almocei no restaurante" | IA pede valor ou registra? Documentar comportamento |
| FIN-C2 | Multi-turno | "gastei no uber" → (aguardar) → "foram 25" | Contexto Redis: IA recupera de rodada anterior |
| FIN-C3 | Typo pesado | "gstei 40 na fmacia" | Classificador entende → criar_gasto |
| FIN-C4 | Emoji no input | "almocei 🍕 50 reais" | Registra sem emoji no name_spent |
| FIN-C5 | Valor zero | "gastei 0 no estacionamento" | Documentar comportamento (aceita? recusa?) |
| FIN-C6 | Valor alto | "recebi 1000000 de herança" | value_spent=1000000 sem truncar |
| FIN-C7 | Nome longo | "gastei 50 no restaurante japonês do shopping perto do parque" | Verificar se name_spent trunca ou grava tudo |
| FIN-C8 | Category match | Criar gasto → comparar category IA vs banco | Registrar divergência se houver |
| FIN-C9 | type_spent | Criar 5 gastos → verificar type_spent nos 5 válidos | Nenhum valor inventado |
| FIN-C10 | fk_user | Após criar → fk_user = user_id teste | Nunca outro user |
| FIN-C11 | date_spent | Criar gasto → date_spent = hoje | Não amanhã, não ontem |
| FIN-C12 | Edit não duplica | Editar → COUNT_DEPOIS = COUNT_ANTES exatamente | Nenhuma duplicata |
| FIN-C13 | Delete não afeta outros | Excluir 1 → COUNT diminui em exatamente 1 | Não apagou mais |
| FIN-C14 | Busca semana passada | "gastos da semana passada" | Range correto nos registros |
| FIN-C15 | Saldo correto | "quanto gastei esse mês?" | Saldo IA = SUM real no banco |

---

## 8. Formato do log de resultado

```markdown
## Execução: {YYYY-MM-DD HH:MM} UTC — Nível: {QUICK|BROAD|COMPLETE}

| Métrica | Valor |
|---------|-------|
| Total   | {n}   |
| Pass    | {n}   |
| Fail    | {n}   |
| Partial | {n}   |
| Timeout | {n}   |

### Detalhes

| ID | Input | IA respondeu | Banco real | N8N | Veredicto |
|----|-------|-------------|------------|-----|-----------|
| FIN-Q1 | gastei 35 no almoço | ✅ Almoço R$35 Alimentação | name=Almoço val=35 cat=Alimentacao | exec:X success | ✅ PASS |

### Divergências
- {ID}: {descrição}

### Bugs
- {descrição com evidência}
```

---

## 9. Problemas conhecidos

| Problema | Impacto | Como lidar no teste |
|----------|---------|---------------------|
| Edição/exclusão async | Banco pode não ter atualizado quando verifico | Esperar 20s após resposta da IA |
| Categoria IA ≠ banco | IA diz "Renda Extra", banco grava "Outros" | Registrar como PARTIAL, não FAIL |
| type_spent inconsistente | Existem "essencial", "essenciais" fora do padrão | Registrar como anomalia |
| Categoria vazia | 1 registro com category_spent="" existe | Verificar se novos repetem |

---

## 10. Melhorias sugeridas no workflow

| O que | Impacto na auditoria | Onde |
|-------|---------------------|------|
| Logar `id_spent` no `log_total` após INSERT/UPDATE/DELETE | Busca por ID em vez de nome | `Financeiro - Total`: adicionar nó Create a row em log_total |
| Logar branch escolhida no `log_total` | Saber se classificou certo | `Fix Conflito v2`: adicionar nó após Switch - Branches1 |
| Audit trigger na tabela `spent` | Verificar edições sem depender de timing | SQL pronto no plano de ação |
| CHECK constraint em `type_spent` | Elimina valores inventados | `ALTER TABLE spent ADD CONSTRAINT chk_type CHECK (type_spent IN ('fixo','variavel','eventuais','emergencias','outros'))` |
| Padronizar categorias | Elimina divergência IA vs banco | Alinhar prompt do AI Agent com lista exata do banco |
