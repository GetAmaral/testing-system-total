# Metodologia de Auditoria — Roteador Principal (Main Workflow)

**Funcionalidade:** `bot-whatsapp/01-roteador-principal`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho da mensagem

```
WhatsApp (Meta API) → webhook trigger (Main - Total Assistente)
  → Check Message Age (code) — rejeita mensagens com mais de 2 min
  → Redis1 — verifica bot_guard (anti-loop)
  → If1 — mensagem é válida?
  → Switch (tipo de mídia):
    ├── texto → segue fluxo
    ├── audio → Download File1 → Get Media Info1 → Transcribe (Whisper) → texto
    └── image/document → Download → OCR/PDF → texto
  → setar_user → Get a row (profiles) — busca dados do user
  → Switch1 (status do user):
    ├── has_profile → verifica plano
    ├── no_profile → onboarding flow (OTP)
    └── inactive → PLANO INATIVO msg
  → If3 (tipo de plano):
    ├── Premium → webhook /premium → Fix Conflito v2
    ├── Standard → Standard User (resposta limitada)
    └── Sem plano → nudge/onboarding
  → Create a row (log_users_messages via AI Messages DB)
  → Send message (WhatsApp response)
```

### Workflow: Main - Total Assistente (`hLwhn94JSHonwHzl`)

**73 nós** — este é o workflow central. Tudo passa por aqui.

### Nós críticos para auditoria

| Nó | Tipo | Função |
|----|------|--------|
| `trigger` | webhook | Recebe POST do WhatsApp |
| `Check Message Age` | code | Rejeita mensagens antigas (>2 min) |
| `Redis1` | redis | Bot guard check |
| `Switch` | switch | Tipo de mídia (texto/audio/image) |
| `setar_user` | set | Prepara dados do user |
| `Get a row` | supabase (profiles) | Busca perfil do user |
| `Switch1` | switch | Status do user (tem perfil?) |
| `If3` | if | Tipo de plano (Premium/Standard) |
| `Premium User` | httpRequest | Chama Fix Conflito v2 |
| `Standard User2/3` | httpRequest | Resposta Standard |
| `Create a row` | supabase | Log no AI Messages DB |

### Tabelas envolvidas

| Tabela | Banco | Operação | Descrição |
|--------|-------|----------|-----------|
| `profiles` | Principal | GET | Dados do user (plano, stage) |
| `messages` | Principal | — | Histórico de mensagens |
| `log_users_messages` | AI Messages | INSERT | Log da conversa |
| `log_total` | AI Messages | INSERT | Log de ações |

---

## 2. Endpoints de verificação

| Verificação | Query |
|-------------|-------|
| User existe | `GET /profiles?select=*&id=eq.{user_id}` (Principal) |
| User por telefone | `GET /profiles?select=*&phone=eq.{phone}` (Principal) |
| Plano do user | `GET /profiles?select=plan_type,plan_status&id=eq.{user_id}` |
| Último log | `GET /log_users_messages?select=*&user_phone=eq.{phone}&order=id.desc&limit=1` (AI Messages) |
| Execuções Main | `GET /executions?workflowId=hLwhn94JSHonwHzl&limit=5` (N8N API) |

---

## 3. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Verificar perfil do user: GET /profiles?id=eq.{user_id}
       → salvar: PROFILE (plan_type, plan_status)
  1.2  Último log_id → LAST_LOG_ID
  1.3  Últimas execuções do Main → EXEC_ANTES

PASSO 2 — ENVIAR MENSAGEM via webhook dev

PASSO 3 — POLLAR RESPOSTA (log_users_messages)

PASSO 4 — VERIFICAR ROTEAMENTO
  4.1  Nova execução apareceu no Main? (GET /executions)
  4.2  Status = success?
  4.3  Se Premium: houve execução do Fix Conflito v2 também?
  4.4  Se Standard: resposta veio do Standard User?
  4.5  Se Inativo: resposta foi mensagem de plano inativo?

PASSO 5 — REGISTRAR
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Mensagem chegou | Nova execução do Main com status=success | Sem execução ou error |
| 2 | User identificado | Log contém dados do user correto | User errado ou não encontrado |
| 3 | Roteamento por plano | Premium→Fix Conflito v2, Standard→resposta limitada | Roteou errado |
| 4 | Resposta entregue | Novo registro em log_users_messages com ai_message | Sem resposta |
| 5 | Mensagem antiga rejeitada | Timestamp >2min → sem processamento | Processou mensagem velha |

---

## 5. Protocolo de diagnóstico de erros

Mesmo protocolo de `financeiro/02-limites-categoria.md` (seção 5), adaptado:

**Camadas específicas do roteador:**
```
CAMADA 1 — WEBHOOK: Mensagem chegou ao trigger? HTTP 200?
CAMADA 2 — MESSAGE AGE: Check Message Age rejeitou indevidamente?
CAMADA 3 — BOT GUARD: Redis1 bloqueou? (anti-loop)
CAMADA 4 — PROFILE: User encontrado no profiles? Plano correto?
CAMADA 5 — SWITCH: Roteou pro fluxo certo (Premium/Standard/Inativo)?
CAMADA 6 — DOWNSTREAM: Fix Conflito v2 ou Standard User executou?
```

---

## 6. Testes

**🟢 Quick (3 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| ROT-Q1 | "oi" (user Premium) | Roteamento Premium | Execução Main + Fix Conflito v2. Resposta no log. |
| ROT-Q2 | "oi" (texto simples) | Mensagem chega e responde | HTTP 200, log criado, ai_message presente |
| ROT-Q3 | Verificar perfil do user | Profile existe | GET /profiles retorna plan_type |

**🟡 Broad (Quick + 5 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| ROT-B1 | User inexistente | Telefone não cadastrado | Fluxo de onboarding ou recusa |
| ROT-B2 | Mensagem com timestamp antigo | >2 min atrás | Rejeitada pelo Check Message Age |
| ROT-B3 | Mensagem vazia | body="" | Não quebra o workflow |
| ROT-B4 | Emoji sozinho | "👋" | Roteado corretamente, resposta coerente |
| ROT-B5 | Mensagem muito longa | 500+ caracteres | Processada sem truncar |

**🔴 Complete (Broad + 5 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| ROT-C1 | Duas mensagens rápidas | Spam leve | Ambas processadas ou segunda bloqueada? |
| ROT-C2 | Verificar latência | Medir tempo webhook→resposta | < 30s? |
| ROT-C3 | Status de execução N8N | Todas as execuções recentes = success | Sem errors |
| ROT-C4 | Log completo | log_users_messages tem user_message + ai_message | Nenhum campo null |
| ROT-C5 | Tipo de mídia no Switch | Enviar texto → confirmar que não foi pra branch audio | Roteamento correto |

---

## 7. Formato do log

```markdown
| ID | Input | Execução Main | Fix Conflito v2? | Log criado? | Veredicto |
|----|-------|---------------|-----------------|-------------|-----------|
```

---

## 8. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Logar qual Switch output foi ativado (texto/audio/image) | Saber o roteamento de mídia |
| Logar qual plano foi identificado | Saber se roteou Premium/Standard |
| Retornar exec_id na resposta do webhook | Rastreio direto |
