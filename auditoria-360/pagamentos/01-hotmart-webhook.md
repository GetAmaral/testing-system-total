# Metodologia de Auditoria — Hotmart Webhook

**Funcionalidade:** `pagamentos/01-hotmart-webhook`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ (webhook externo Hotmart)
**Testável via simulação:** ✅ SIM (simular payload Hotmart no webhook do N8N)

---

## 1. Mapa do sistema

### Caminho

```
Hotmart (compra/cancelamento) → webhook N8N (Main ou dedicado)
  → Processa evento (purchase_complete, subscription_cancellation, etc)
  → INSERT/UPDATE payments
  → INSERT/UPDATE subscriptions
  → UPDATE profiles (plan_type, plan_status)
  → Pode enviar WhatsApp de confirmação
```

### Tabelas

| Tabela | Campos-chave |
|--------|-------------|
| `payments` | user_id, plan_type, amount, status, transaction_id, created_at |
| `subscriptions` | user_id, current_plan, status, start_date, end_date, grace_period_end |
| `profiles` | plan_type, plan_status |

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  GET /payments?user_id=eq.{user_id} → PAYMENTS_ANTES
  1.2  GET /subscriptions?user_id=eq.{user_id} → SUBS_ANTES
  1.3  GET /profiles?id=eq.{user_id} → PROFILE_ANTES (plan_type, plan_status)

PASSO 2 — SIMULAR WEBHOOK HOTMART (se endpoint existir no dev)
  Ou: análise estática dos nós

PASSO 3 — VERIFICAR
  3.1  payments: novo registro?
  3.2  subscriptions: status atualizado?
  3.3  profiles: plan_type/plan_status atualizado?
```

---

## 3. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| HOT-Q1 | Tabela payments tem registros (schema correto) |
| HOT-Q2 | Tabela subscriptions tem registro pro user |

**🟡 Broad (+3):**

| ID | Verificação |
|----|-------------|
| HOT-B1 | Consistência: payments.plan_type = subscriptions.current_plan = profiles.plan_type |
| HOT-B2 | Verificar nós de webhook Hotmart no Main (análise estática) |
| HOT-B3 | Execuções passadas com webhook de pagamento |

**🔴 Complete (+3):**

| ID | Verificação |
|----|-------------|
| HOT-C1 | Simular payload de compra (se webhook existir no dev) |
| HOT-C2 | Simular cancelamento |
| HOT-C3 | Verificar que plan_status muda corretamente em cascata |

---

## 4. Protocolo de diagnóstico

```
CAMADA 1 — WEBHOOK: Endpoint de Hotmart existe no N8N dev?
CAMADA 2 — PARSING: Payload Hotmart parseado corretamente?
CAMADA 3 — PAYMENTS: INSERT executou?
CAMADA 4 — SUBSCRIPTIONS: UPDATE executou?
CAMADA 5 — PROFILES: plan_type/plan_status atualizaram?
CAMADA 6 — WHATSAPP: Confirmação enviada ao user?
```
