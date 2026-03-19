# Metodologia de Auditoria — Login via OTP

**Funcionalidade:** `autenticacao/01-login-otp`
**Versão:** 1.0.0
**Testável via WhatsApp:** PARCIAL (fluxo de onboarding por OTP existe no Main workflow)

---

## 1. Mapa do sistema

### Caminho (onboarding via WhatsApp)

```
Main - Total Assistente:
  → User envia msg pela 1ª vez → profiles: sem perfil
  → Switch1 → branch onboarding
    → create-onboarding-user (httpRequest) — cria user
    → Switch stg4 (stage do onboarding):
      ├── stage 2 → pede email
      ├── stage 3 → Verify OTP Code (httpRequest) → valida código
      │   ├── OK → Update stg to 5 → Msg Conta Ativada
      │   └── FAIL → Msg Código Inválido
      ├── stage 4 → Reenviar OTP / Corrigir Email
      └── stage 5/6 → conta ativa → fluxo normal
```

### Tabelas

| Tabela | Campos relevantes |
|--------|-------------------|
| `profiles` | id, email, phone, name, plan_type, plan_status, created_at |
| `pending_2fa_sessions` | Sessões OTP pendentes |

### Nós no Main

| Nó | Função |
|----|--------|
| `create-onboarding-user` | Cria user no Supabase Auth |
| `Verify OTP Code` / `Verify OTP Code1` | Valida código OTP |
| `Switch stg4` | Switch por stage do onboarding |
| `Msg Conta Ativada` / `Msg Código Inválido` | Respostas WhatsApp |
| `Reenviar OTP` | Reenvia código |
| `Corrigir volta stg 2` | Volta pra pedir email |

---

## 2. Algoritmo de execução

```
PASSO 1 — Verificar profiles do user de teste → já existe com plano ativo

PASSO 2 — Como user de teste JÁ TEM perfil, NÃO é possível testar onboarding com ele
  Opção A: Criar user de teste novo (telefone diferente)
  Opção B: Análise estática dos nós do workflow
  Opção C: Verificar execuções passadas de onboarding

PASSO 3 — Análise estática: GET /api/v1/workflows/hLwhn94JSHonwHzl
  → Verificar nós de OTP existem e estão conectados

PASSO 4 — Verificar execuções com onboarding
  → GET /executions?workflowId=hLwhn94JSHonwHzl&limit=50
  → Filtrar as que passaram por Switch stg4
```

---

## 3. Testes

**🟢 Quick (2):**

| ID | Tipo | Verificação |
|----|------|-------------|
| OTP-Q1 | Análise estática | Nós de OTP existem e estão conectados no Main |
| OTP-Q2 | Verificar profiles | User de teste tem email, phone, plan_type preenchidos |

**🟡 Broad (+3):**

| ID | Tipo | Verificação |
|----|------|-------------|
| OTP-B1 | Execuções passadas | Existem onboardings que deram success? |
| OTP-B2 | pending_2fa_sessions | Tabela tem sessões? Schema correto? |
| OTP-B3 | OTP inválido | Nos execuções passadas, houve rejeição de código errado? |

**🔴 Complete (+3):**

| ID | Tipo | Verificação |
|----|------|-------------|
| OTP-C1 | Criar user novo (se possível) | Fluxo completo de onboarding |
| OTP-C2 | Reenvio de OTP | Nó Reenviar OTP funciona |
| OTP-C3 | Correção de email | Nó Corrigir volta stg 2 funciona |

---

## 4. Protocolo de diagnóstico / Melhorias

Mesmo protocolo base. **Limitação principal:** user de teste já ativado — precisa de user novo pra teste end-to-end.
