# Metodologia de Auditoria — VIP Calendar

**Funcionalidade:** `agenda/08-vip-calendar`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### O que é

Sistema de calendário baseado em telefone (sem autenticação). Usa tabela separada `calendar_vip` e conexões Google via `vip_google_connections`.

### Tabela: `calendar_vip`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Verificar via Supabase | — | Schema similar a `calendar` mas com acesso por telefone |

### Tabela: `vip_google_connections`

| Campo | Tipo | Descrição |
|-------|------|-----------|
| Verificar via Supabase | — | Tokens Google para VIP users |

### RPCs relacionadas

- `get_vip_connection_status` — verifica se VIP user tem Google conectado
- `get_vip_google_tokens` — busca tokens do VIP user
- `store_vip_google_connection` — salva conexão Google VIP

### Limitação

Watson testa com user que tem `calendar` normal (não VIP). Para testar VIP:
1. Verificar schema da tabela `calendar_vip`
2. Verificar se existem registros
3. Verificar RPCs
4. Testar requer user VIP dedicado

---

## 2. Algoritmo de execução

```
PASSO 1 — Análise de schema
  GET /calendar_vip?select=*&limit=1 → entender campos

PASSO 2 — Verificar registros existentes
  GET /calendar_vip?select=id → contar total

PASSO 3 — Verificar vip_google_connections
  GET /vip_google_connections?select=*&limit=1 → schema

PASSO 4 — Verificar RPCs
  POST /rpc/get_vip_connection_status → funciona?

PASSO 5 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Tabela existe | calendar_vip acessível | Não existe |
| 2 | Schema coerente | Campos similares a calendar | Incompleto |
| 3 | RPCs funcionam | Retornam dados válidos | Erro |
| 4 | Isolamento | VIP não interfere com calendar normal | Dados cruzados |

---

## 4. Protocolo de diagnóstico de erros

```
CAMADA 1 — TABELA: calendar_vip existe e é acessível?
CAMADA 2 — RPC: Funções VIP retornam dados?
CAMADA 3 — GOOGLE: vip_google_connections tem tokens válidos?
CAMADA 4 — ISOLAMENTO: Dados VIP separados dos normais?
```

---

## 5. Testes

**🟢 Quick (2 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| VIP-Q1 | Verificar tabela | calendar_vip existe, schema documentado |
| VIP-Q2 | Verificar conexões | vip_google_connections tem dados? |

**🟡 Broad (Quick + 3 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| VIP-B1 | RPCs VIP | get_vip_connection_status funciona |
| VIP-B2 | Registros VIP | Existem eventos em calendar_vip? |
| VIP-B3 | Isolamento | calendar e calendar_vip não compartilham dados |

**🔴 Complete (Broad + 2 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| VIP-C1 | Criar evento VIP (se possível) | CRUD funciona em calendar_vip |
| VIP-C2 | Google sync VIP | Tokens VIP válidos, sync funciona |

---

## 6. Limitações

| Limitação | Impacto |
|-----------|---------|
| User de teste é normal, não VIP | Precisa de user VIP dedicado |
| Workflow VIP pode não estar no N8N dev | Verificar se existe |

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Criar user VIP de teste | Testes end-to-end de VIP |
| Documentar diferenças calendar vs calendar_vip | Clareza pra auditoria |
