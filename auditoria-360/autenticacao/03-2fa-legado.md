# Metodologia de Auditoria — 2FA Legado

**Funcionalidade:** `autenticacao/03-2fa-legado`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ NÃO (frontend)

---

## 1. Mapa do sistema

### Tabelas

| Tabela | Função |
|--------|--------|
| `two_factor_sessions` | Sessões 2FA ativas |
| `pending_2fa_sessions` | Sessões pendentes de validação |

### RPCs

- `create_2fa_session` — cria sessão
- `verify_2fa_session` — valida
- `complete_2fa_session` — completa
- `cleanup_expired_2fa_sessions` — limpa expiradas

---

## 2. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| 2FA-Q1 | Tabelas existem e são acessíveis |
| 2FA-Q2 | RPCs retornam sem erro |

**🟡 Broad (+2):**

| ID | Verificação |
|----|-------------|
| 2FA-B1 | Sessões expiradas são limpas (cleanup RPC) |
| 2FA-B2 | Schema coerente com fluxo de 2FA |

---

## 3. Limitações

100% frontend. Watson verifica apenas estado das tabelas e RPCs.
