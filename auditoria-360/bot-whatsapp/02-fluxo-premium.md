# Metodologia de Auditoria — Fluxo Premium (AI Agent)

**Funcionalidade:** `bot-whatsapp/02-fluxo-premium`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
Main → webhook /premium → Fix Conflito v2 (ImW2P52iyCS0bGbQ)
  → setar_user (prepara dados)
  → Aggregate (dados do user)
  → Aggregate3 (limites)
  → infos (data + colocar_limite + agora)
  → firstGet/mediumGet/lastGet (Redis — histórico de conversa)
  → Escolher Branch (classificador LLM — GPT-4.1-mini)
    → Output: { "branch": "criar_gasto" }
  → Switch - Branches1 (12 branches)
    ├── criar_gasto → registrar_gasto (prompt) → AI Agent → tools HTTP
    ├── buscar → buscar_gasto (prompt) → AI Agent → tools HTTP
    ├── editar → editar_gasto (prompt) → AI Agent → tools HTTP
    ├── excluir → excluir2 (prompt) → AI Agent → tools HTTP
    ├── criar_evento_agenda → prompt_criar1 → AI Agent → tools HTTP
    ├── buscar_evento_agenda → prompt_busca1 → AI Agent → tools HTTP
    ├── editar_evento_agenda → prompt_editar1 → AI Agent → tools HTTP
    ├── excluir_evento_agenda → prompt_excluir → AI Agent → tools HTTP
    ├── criar_lembrete_agenda → prompt_lembrete → AI Agent → tools HTTP
    ├── criar_evento_recorrente → prompt_lembrete1 → AI Agent → tools HTTP
    ├── gerar_relatorio → prompt_rel → AI Agent → tools HTTP
    └── padrao → padrao (prompt genérico) → AI Agent
  → AI Agent responde JSON
  → Resposta enviada via WhatsApp
  → Log em log_users_messages + pushRedisMessage (histórico)
```

### Workflow: Fix Conflito v2 (`ImW2P52iyCS0bGbQ`) — 147 nós

### Componentes-chave

| Componente | Nó | Função |
|-----------|-----|--------|
| Classificador | `Escolher Branch` (chainLlm) | Decide a intenção. Output: JSON com branch |
| Router | `Switch - Branches1` | Roteia pra branch correta |
| Prompt setter | `registrar_gasto`, `buscar_gasto`, etc. | Seta o prompt específico |
| AI Agent | `AI Agent` (GPT-4.1-mini) | Processa com tools |
| Memória | `Redis Chat Memory` | Contexto multi-turno |
| Tools | `buscar_financeiro`, `editar_financeiro`, etc. | HTTP calls pra workflows secundários |

### 12 Branches do classificador

```
criar_gasto, buscar, editar, excluir,
criar_evento_agenda, buscar_evento_agenda, editar_evento_agenda, excluir_evento_agenda,
criar_lembrete_agenda, criar_evento_recorrente,
gerar_relatorio, padrao
```

---

## 2. Endpoints de verificação

Mesmos de `financeiro/01-despesas-receitas.md` + execuções do Fix Conflito v2:

| Verificação | Query |
|-------------|-------|
| Execuções Fix Conflito | `GET /executions?workflowId=ImW2P52iyCS0bGbQ&limit=5` |

---

## 3. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Último log_id → LAST_LOG_ID
  1.2  Últimas execuções Fix Conflito v2 → EXEC_ANTES

PASSO 2 — ENVIAR MENSAGEM

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — VERIFICAR CLASSIFICAÇÃO
  4.1  GET /executions (Fix Conflito v2) → nova execução
  4.2  Verificar status = success
  4.3  Inferir branch pela resposta da IA:
       - "✅ Gasto registrado" → branch foi criar_gasto
       - "✅ Busca completa" → branch foi buscar
       - "✅ Edição concluída" → branch foi editar
       - "🗑️ Exclusão concluída" → branch foi excluir
       - "✅ Evento agendado" → branch foi criar_evento_agenda
       - Resposta genérica → branch foi padrao

PASSO 5 — VERIFICAR RESULTADO (banco) — depende da branch

PASSO 6 — REGISTRAR
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Classificação correta | Branch corresponde à intenção real | Branch errada |
| 2 | AI Agent respondeu | ai_message presente e não vazio | Sem resposta ou erro |
| 3 | JSON válido | Resposta é JSON com "acao" e "mensagem" | Malformado |
| 4 | Tools chamadas | Agent invocou tools necessárias (buscar/editar/etc) | Não chamou |
| 5 | Redis memória | Contexto multi-turno funciona ("e amanhã?") | Sem contexto |
| 6 | Recusa correta | Imperativo (paga, transfere) → padrao com recusa | Registrou |

---

## 5. Protocolo de diagnóstico de erros

Mesmo protocolo base, com camadas específicas:

```
CAMADA 1 — CLASSIFICADOR: Escolher Branch decidiu errado?
  → Verificar prompt do classificador vs input
  → Causa: cenário não coberto no prompt

CAMADA 2 — PROMPT SETTER: Prompt da branch correta foi setado?
  → Verificar nó registrar_gasto/buscar_gasto/etc

CAMADA 3 — AI AGENT: Agent raciocinou e chamou tools?
  → Verificar execution detail

CAMADA 4 — TOOLS: Tool HTTP retornou sucesso?
  → Verificar execução do workflow secundário

CAMADA 5 — REDIS: Memória de conversa está correta?
  → Verificar se contexto anterior foi recuperado
```

---

## 6. Testes

**🟢 Quick (5 testes):**

| ID | Input | Branch esperada | Verificação |
|----|-------|-----------------|-------------|
| PREM-Q1 | "gastei 30 no almoço" | criar_gasto | IA: "✅ Gasto registrado". spent: +1 |
| PREM-Q2 | "o que tenho amanhã?" | buscar_evento_agenda | IA retorna agenda |
| PREM-Q3 | "oi, tudo bem?" | padrao | Resposta genérica. Nada criado. |
| PREM-Q4 | "paga meu boleto de 200" | padrao | Recusa. Nada criado. |
| PREM-Q5 | "gera meu relatório" | gerar_relatorio | IA: "relatório sendo gerado" |

**🟡 Broad (Quick + 7 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| PREM-B1 | "e ontem?" (após Q2) | Multi-turno: Redis recupera contexto de agenda |
| PREM-B2 | "quem é o presidente?" | padrao: fora do escopo |
| PREM-B3 | "muda o almoço pra 45" | editar: branch correta + edição async |
| PREM-B4 | "apaga o almoço" | excluir: branch correta + exclusão async |
| PREM-B5 | "reunião amanhã 10h" | criar_evento_agenda |
| PREM-B6 | "academia toda segunda 7h" | criar_evento_recorrente |
| PREM-B7 | "😂" | padrao: emoji sozinho |

**🔴 Complete (Broad + 5 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| PREM-C1 | Mensagem ambígua: "pizza 30" | Classificador decide criar_gasto ou padrao? |
| PREM-C2 | "sim" (após pergunta) | Redis: continuação de contexto |
| PREM-C3 | 3 mensagens em sequência rápida | Rate limiting / concorrência |
| PREM-C4 | Mensagem com 1000 caracteres | Processamento sem truncar |
| PREM-C5 | Verificar todas as 12 branches | 12 inputs, 1 por branch → todas funcionam |

---

## 7. Formato do log

```markdown
| ID | Input | Branch inferida | IA respondeu | Banco verificado | N8N exec | Veredicto |
```

---

## 8. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Logar branch escolhida no log_total | Saber classificação sem inferir |
| Logar tools chamadas pelo AI Agent | Ver cadeia completa |
| Logar confiança do classificador | Detectar ambiguidades |
