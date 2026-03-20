# Teste FIN-DET-01 — Criar Gasto

**Funcionalidade:** financeiro/01-despesas-receitas
**Operacao:** CREATE
**Data:** 2026-03-20T13:55:44Z
**Veredicto:** PASS (com anomalia ERR-001)

---

## 1. Configuracao do teste

| Parametro | Valor |
|-----------|-------|
| Input | "gastei 45 no sushi" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User de teste | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Nivel | Quick |
| Operacao esperada | INSERT na tabela `spent` |

## 2. Metodo utilizado

```
PASSO 1: Snapshot ANTES
  - Contou registros no spent (fk_user=user_teste) → 84
  - Salvou ultimo log_id em log_users_messages → 3903
  - Registrou timestamp UTC → 2026-03-20T13:55:44Z

PASSO 2: Envio
  - POST http://76.13.172.17:5678/webhook/dev-whatsapp
  - Payload WhatsApp padrao com body: "gastei 45 no sushi"
  - HTTP 200 + "Workflow was started"

PASSO 3: Poll resposta
  - Polled log_users_messages a cada 3s (max 45s)
  - Novo log_id: 3908 (apareceu em ~4s)

PASSO 4: Verificacao banco
  - Contou spent DEPOIS → 85 (delta: +1)
  - Buscou por name_spent ILIKE '%Sushi%' → encontrado

PASSO 5: Execucoes N8N
  - Main (11566): success
  - Fix Conflito v2 (11567): success
  - Financeiro - Total (11568): ERROR ← anomalia

PASSO 6: Cruzamento campo a campo
```

## 3. Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 84 |
| last_log_id | 3903 |
| timestamp | 2026-03-20T13:55:44Z |

## 4. Resposta da IA

| Campo | Valor |
|-------|-------|
| log_id | 3908 |
| user_message | gastei 45 no sushi |
| ai_message | Gasto registrado! Nome: Sushi Valor: R$45 Categoria: Alimentacao |
| created_at | 2026-03-20T13:55:48Z |
| uuid | 706184ae-90f1-4c74-ae04-882efac9033d |

## 5. Snapshot DEPOIS

| Metrica | Valor |
|---------|-------|
| spent count | 85 (delta: +1) |

## 6. Registro encontrado no banco

| Campo | Valor no banco | IA disse | Match? |
|-------|---------------|----------|--------|
| id_spent | aab3dae1-4ef0-4374-97fe-a260fe182d83 | (nao informou) | — |
| name_spent | Sushi | Sushi | SIM |
| value_spent | 45 | R$45 | SIM |
| category_spent | Alimentacao | Alimentacao | SIM |
| transaction_type | saida | (implicito: gasto) | SIM |
| type_spent | variavel | (nao informou) | COERENTE |
| date_spent | 2026-03-20 | (hoje) | SIM |
| fk_user | 2eb4065b-... | (user de teste) | SIM |
| created_at | 2026-03-20T10:55:51 BRT | — | OK |

## 7. Execucoes N8N

| Workflow | ID Workflow | Exec ID | Status | Timestamp |
|----------|------------|---------|--------|-----------|
| Main - Total Assistente | hLwhn94JSHonwHzl | 11566 | success | 13:55:44Z |
| Fix Conflito v2 | ImW2P52iyCS0bGbQ | 11567 | success | 13:55:49Z |
| Financeiro - Total | NCVLUtTn656ACUGS | **11568** | **error** | 13:55:51Z |

## 8. Veredicto

**PASS** — O gasto foi criado corretamente no banco com todos os campos corretos.

**Anomalia:** Workflow Financeiro - Total (exec 11568) retornou status=error apesar do INSERT ter funcionado. Documento de erro gerado: **ERR-001**.

## 9. Erros relacionados

| Erro | Descricao |
|------|-----------|
| ERR-001 | Workflow Financeiro retorna ERROR mesmo com gasto criado. Possivel falha no no de logging pos-INSERT. |

---

*Teste executado por @auditor (Lupa) — 2026-03-20*
