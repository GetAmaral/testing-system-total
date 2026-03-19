# Metodologia de Auditoria — RBAC e Controle de Planos

**Funcionalidade:** `autenticacao/04-rbac-planos`
**Versão:** 1.0.0
**Testável via WhatsApp:** ✅ SIM (roteamento Premium/Standard no Main)

---

## 1. Mapa do sistema

### Caminho no Main workflow

```
Main → setar_user → Get a row (profiles)
  → If3: plan_type == "premium"?
    ├── SIM → Premium User (Fix Conflito v2)
    └── NÃO → Standard User2/3
  → Se plano inativo → PLANO INATIVO msg
```

### Tabelas

| Tabela | Campos relevantes |
|--------|-------------------|
| `profiles` | plan_type ("premium"/"standard"), plan_status ("active"/"inactive"/"cancelled") |
| `subscriptions` | status, current_plan, start_date, end_date, grace_period_end |
| `user_roles` | Roles do user |
| `payments` | Histórico de pagamentos |

### RPCs

- `get_active_plan` — retorna plano ativo
- `user_has_premium` / `user_has_standard` — verificadores
- `sync_profile_plan` — sincroniza plano com subscription

---

## 2. Algoritmo de execução

```
PASSO 1 — Verificar profiles do user de teste
  GET /profiles?id=eq.{user_id} → plan_type, plan_status

PASSO 2 — Verificar subscriptions
  GET /subscriptions?user_id=eq.{user_id} → status, current_plan

PASSO 3 — Enviar mensagem e verificar roteamento
  Se Premium → Fix Conflito v2 deve executar
  Se Standard → Standard User deve responder
  Se Inativo → Mensagem de plano inativo

PASSO 4 — Verificar via N8N executions qual workflow executou
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Premium → Fix Conflito v2 | Execução do Fix Conflito v2 | Não executou |
| 2 | Standard → resposta limitada | Sem Fix Conflito v2 | Executou Premium |
| 3 | Inativo → mensagem de bloqueio | "Plano inativo" | Processou normalmente |
| 4 | profiles.plan_type correto | Bate com subscription.current_plan | Divergente |

---

## 4. Testes

**🟢 Quick (3):**

| ID | Input | Verificação |
|----|-------|-------------|
| RBAC-Q1 | Verificar profiles | plan_type e plan_status corretos |
| RBAC-Q2 | Verificar subscriptions | Status da assinatura |
| RBAC-Q3 | Enviar "oi" | Roteou pro fluxo correto (Premium) |

**🟡 Broad (+4):**

| ID | Verificação |
|----|-------------|
| RBAC-B1 | RPCs: user_has_premium retorna true pro user de teste |
| RBAC-B2 | RPCs: get_active_plan retorna plano correto |
| RBAC-B3 | Consistência profiles vs subscriptions |
| RBAC-B4 | user_roles do user de teste |

**🔴 Complete (+3):**

| ID | Verificação |
|----|-------------|
| RBAC-C1 | Verificar grace_period_end (período de carência) |
| RBAC-C2 | sync_profile_plan RPC funciona |
| RBAC-C3 | Se possível: testar user inativo (precisa user separado) |

---

## 5. Protocolo de diagnóstico

```
CAMADA 1 — PROFILES: plan_type está correto?
CAMADA 2 — SUBSCRIPTION: Assinatura ativa?
CAMADA 3 — MAIN SWITCH: If3 roteou pelo plano correto?
CAMADA 4 — CONSISTÊNCIA: profiles.plan_type = subscriptions.current_plan?
```
