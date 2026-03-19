# Metodologia de Auditoria — Gestão de Conta

**Funcionalidade:** `autenticacao/05-gestao-conta`
**Versão:** 1.0.0
**Testável via WhatsApp:** ❌ NÃO (frontend)

---

## 1. Mapa

Gestão de conta (alterar nome, email, excluir conta) é feita pelo frontend React. Watson verifica apenas o estado das tabelas.

### Tabelas

| Tabela | Operação |
|--------|----------|
| `profiles` | UPDATE (nome, email, avatar_url) |
| auth.users (Supabase Auth) | DELETE (excluir conta) |

---

## 2. Testes

**🟢 Quick (2):**

| ID | Verificação |
|----|-------------|
| CONTA-Q1 | profiles tem todos os campos preenchidos pro user de teste |
| CONTA-Q2 | email, phone, name consistentes |

**🟡 Broad (+2):**

| ID | Verificação |
|----|-------------|
| CONTA-B1 | updated_at é recente (conta está sendo usada) |
| CONTA-B2 | Verificar RPC find_profile_by_email / find_profile_by_phone |

---

## 3. Limitações

Watson não pode alterar dados de conta nem excluir conta via WhatsApp. Apenas verificação de estado.
