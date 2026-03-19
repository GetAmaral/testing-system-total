# Metodologia de Auditoria — Gestão de Assinatura

**Funcionalidade:** `pagamentos/03-gestao-assinatura`
**Versão:** 1.0.0
**Testável via WhatsApp:** PARCIAL (user pode perguntar "qual meu plano?" — IA responde)

---

## 1. Mapa do sistema

### Via WhatsApp

```
User: "qual meu plano?" → Fix Conflito v2 → branch padrao
  → AI Agent lê profiles.plan_type → responde
```

### Via frontend

Cancelar/reativar plano → UPDATE subscriptions + profiles.

### Tabelas

| Tabela | Campos |
|--------|--------|
| `subscriptions` | status (active/cancelled/expired), current_plan, end_date, grace_period_end |
| `profiles` | plan_type, plan_status |
| `payments` | Histórico |

### RPCs

- `can_user_cancel_plan` — verifica se pode cancelar
- `get_my_plan_data` — retorna dados do plano
- `find_subscription_by_phone` — busca por telefone

---

## 2. Algoritmo

```
PASSO 1 — Verificar subscriptions do user
PASSO 2 — Verificar profiles.plan_type e plan_status
PASSO 3 — Testar via WhatsApp: "qual meu plano?" → verificar resposta
PASSO 4 — Verificar consistência entre tabelas
```

---

## 3. Testes

**🟢 Quick (3):**

| ID | Input | Verificação |
|----|-------|-------------|
| SUB-Q1 | Verificar subscriptions | Registro existe, status correto |
| SUB-Q2 | Verificar profiles | plan_type e plan_status corretos |
| SUB-Q3 | "qual meu plano?" (WhatsApp) | IA responde corretamente |

**🟡 Broad (+3):**

| ID | Verificação |
|----|-------------|
| SUB-B1 | RPCs: get_my_plan_data retorna dados corretos |
| SUB-B2 | Consistência: subscriptions.current_plan = profiles.plan_type |
| SUB-B3 | grace_period_end: se cancelado, período de carência definido |

**🔴 Complete (+2):**

| ID | Verificação |
|----|-------------|
| SUB-C1 | Simular cancelamento (se possível via banco) → plan_status muda |
| SUB-C2 | Reativação: se reativar, plan_status volta a "active" |

---

## 4. Protocolo de diagnóstico

```
CAMADA 1 — TABELAS: subscriptions e profiles consistentes?
CAMADA 2 — WHATSAPP: IA informa plano correto?
CAMADA 3 — RPCs: Funções de plano retornam dados válidos?
CAMADA 4 — CASCATA: Mudança em subscriptions reflete em profiles?
```
