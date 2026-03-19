# Metodologia de Auditoria — Portfolio de Investimentos

**Funcionalidade:** `investimentos/01-portfolio`
**Versão:** 1.0.0
**Status:** ⚠️ Tabela existe mas SEM workflow N8N. IA recusa via WhatsApp.

---

## 1. Mapa do sistema

### Diagnóstico

| Componente | Existe? | Detalhe |
|-----------|---------|---------|
| Tabela `investments` | ✅ | Campos: investment_type, name, amount_invested, current_value, profit_loss, notes |
| Branch no classificador | ❌ | Não há branch para investimentos |
| Prompt do agent | ❌ | Diz pra NÃO registrar investimentos como gasto |
| Workflow N8N | ❌ | Nenhum workflow CRUD de investimentos |
| Frontend | ✅ | App React tem tela de investimentos |

### Tabela: `investments`

| Campo | Tipo |
|-------|------|
| `id` | UUID |
| `user_id` | UUID |
| `investment_type` | TEXT (bitcoin, cdb, etc) |
| `name` | TEXT |
| `amount_invested` | NUMERIC |
| `current_value` | NUMERIC |
| `profit_loss` | NUMERIC |
| `investment_date` | TIMESTAMP |
| `notes` | TEXT |
| `created_at` / `updated_at` | TIMESTAMP |

### Dados existentes

Existem registros na tabela (de outro user — bb2c8e4e), com types "bitcoin" e nomes "BTC", "Teste".

---

## 2. O que testar

### Via WhatsApp: verificar RECUSA correta

| Input | Esperado |
|-------|----------|
| "aplica 2000 em CDB" | NÃO registra. Branch = padrao. |
| "investe 500 em bitcoin" | NÃO registra. Recusa. |
| "meus investimentos" | Recusa ou redireciona pro app |

### Via banco: verificar integridade

| Verificação |
|-------------|
| Tabela investments acessível |
| Schema correto |
| Dados não corrompidos |

---

## 3. Testes

**🟢 Quick (2):**

| ID | Input | Verificação |
|----|-------|-------------|
| INV-Q1 | "investe 500 em bitcoin" | Recusa. spent NÃO aumentou. investments NÃO aumentou. |
| INV-Q2 | Verificar tabela investments | Schema correto, dados existentes |

**🟡 Broad (+3):**

| ID | Input | Verificação |
|----|-------|-------------|
| INV-B1 | "aplica 2000 em CDB" | Recusa. NÃO registra como gasto. |
| INV-B2 | "meus investimentos" | Recusa ou informa que é pelo app |
| INV-B3 | "quanto tenho investido?" | Recusa (não tem acesso aos dados via WhatsApp) |

**🔴 Complete (+2):**

| ID | Verificação |
|----|-------------|
| INV-C1 | Nenhum dos inputs acima criou registro em investments NEM em spent |
| INV-C2 | User de teste não tem registros em investments (isolamento) |

---

## 4. Melhorias sugeridas

| O que | Decisão |
|-------|---------|
| Criar workflow CRUD de investimentos | PO decide roadmap |
| Branch `investimentos` no classificador | PO decide |
| Integrar tabela investments com relatórios | PO decide |
