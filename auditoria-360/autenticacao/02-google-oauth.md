# Metodologia de Auditoria — Google OAuth Login

**Funcionalidade:** `autenticacao/02-google-oauth`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ NÃO (100% frontend)

---

## 1. Mapa do sistema

Google OAuth é feito inteiramente pelo frontend (React). Watson pode apenas verificar tabelas.

### Tabelas

| Tabela | Função |
|--------|--------|
| `google_calendar_connections` | Conexões Google ativas |
| `crypto_keys` | Chaves de criptografia pra tokens |
| `decrypted_google_connections` | View de conexões descriptografadas |

---

## 2. Algoritmo

```
PASSO 1 — Verificar google_calendar_connections do user
  GET /google_calendar_connections?user_id=eq.{user_id}
  → Conexão existe? Tokens presentes?

PASSO 2 — Verificar profiles.google_connect_status
  → Status da conexão Google
```

---

## 3. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| GOAUTH-Q1 | google_calendar_connections tem registro pro user de teste |
| GOAUTH-Q2 | profiles.google_connect_status está preenchido |

**🟡 Broad (+2):**

| ID | Verificação |
|----|-------------|
| GOAUTH-B1 | Tokens não expirados |
| GOAUTH-B2 | RPCs: get_google_tokens, get_access_token funcionam |

---

## 4. Limitações

Watson não testa o fluxo OAuth em si (redirect, consent screen, token exchange). Só verifica estado no banco.
