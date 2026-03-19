# Metodologia de Auditoria — Checkout e Planos

**Funcionalidade:** `pagamentos/02-checkout-planos`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ NÃO (frontend + Hotmart)

---

## 1. Mapa do sistema

Checkout é feito pelo frontend (React) → redirect para Hotmart → webhook de retorno.

### Tabelas

| Tabela | Função |
|--------|--------|
| `short_links` | Links curtos para páginas de checkout |
| `payments` | Registros de pagamento |
| `subscriptions` | Assinaturas ativas |

---

## 2. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| CHK-Q1 | short_links: existem links de checkout? Schema? |
| CHK-Q2 | payments: registros existentes com status correto |

**🟡 Broad (+2):**

| ID | Verificação |
|----|-------------|
| CHK-B1 | short_links: clicks contabilizados (increment_short_link_clicks RPC) |
| CHK-B2 | Planos disponíveis: quais plan_types existem no sistema |

---

## 3. Limitações

Watson não pode navegar pelo frontend nem completar checkout. Verificação apenas de tabelas.
