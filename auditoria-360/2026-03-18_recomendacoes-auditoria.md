# Recomendações para Auditoria 360° — O que implementar no sistema

**Data:** 2026-03-18
**Agente:** @testador (Watson)

---

## O que é BURRO no jeito que eu testo hoje

### 1. Eu espero `sleep 18` cego, sem saber se processou

**Hoje:** Eu mando a mensagem e faço `sleep 18` torcendo pra ter processado. Às vezes 18s não basta e eu pego a resposta do teste anterior.

**Solução:** O N8N deveria ter um **callback ou flag** que indica "processamento completo". Alternativas:
- Um campo `status` na `log_users_messages` (pending → complete)
- Ou eu pollar a tabela `log_users_messages` até o log_id ser maior que o anterior (em vez de sleep fixo)

**Quem implementa:** @dev no workflow N8N ou Watson pode pollar em vez de sleep.

---

### 2. Eu não tenho como saber o ID do registro que foi criado

**Hoje:** Eu mando "gastei 47 na pizza" e depois busco no banco por `name_spent=Pizza`. Se já existir outro "Pizza" de testes anteriores, eu posso pegar o registro errado.

**Solução:** A resposta da IA deveria incluir o **ID do registro** criado/editado/deletado. Exemplo:
```
✅ Gasto registrado!
📝 Nome: Pizza 💰 Valor: R$47
🆔 ID: 7a2b3f0c-a5e4-4ea1-b39d-8518d58ca3b2
```

**Quem implementa:** @dev — adicionar `id_spent` ou `id` do calendar na resposta da IA (pode ser oculto pro user mas visível no log).

**Alternativa mais simples:** Usar um **prefixo de teste** nos nomes (ex: `TEST_Pizza`) para não conflitar com dados reais. Watson já faria isso automaticamente.

---

### 3. Não existe audit log de edições

**Hoje:** Se a IA diz "editei valor pra R$55" mas o banco ainda tem R$47, eu descubro na verificação. Mas se a IA diz "editei" e o banco mostra R$55, eu não sei SE a edição realmente aconteceu ou se o valor já era R$55 antes.

**Solução:** Trigger no PostgreSQL que grava INSERT/UPDATE/DELETE automaticamente:

```sql
CREATE TABLE audit_spent (
  id SERIAL PRIMARY KEY,
  action TEXT,              -- INSERT, UPDATE, DELETE
  record_id UUID,           -- id_spent
  old_values JSONB,         -- estado anterior
  new_values JSONB,         -- estado novo
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  changed_by TEXT           -- 'n8n-workflow' ou 'manual'
);

CREATE OR REPLACE FUNCTION audit_spent_changes()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_spent(action, record_id, new_values)
    VALUES ('INSERT', NEW.id_spent, to_jsonb(NEW));
  ELSIF TG_OP = 'UPDATE' THEN
    INSERT INTO audit_spent(action, record_id, old_values, new_values)
    VALUES ('UPDATE', NEW.id_spent, to_jsonb(OLD), to_jsonb(NEW));
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_spent(action, record_id, old_values)
    VALUES ('DELETE', OLD.id_spent, to_jsonb(OLD));
  END IF;
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_spent
AFTER INSERT OR UPDATE OR DELETE ON spent
FOR EACH ROW EXECUTE FUNCTION audit_spent_changes();
```

O mesmo para a tabela `calendar`:

```sql
CREATE TABLE audit_calendar (
  id SERIAL PRIMARY KEY,
  action TEXT,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  changed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TRIGGER trg_audit_calendar
AFTER INSERT OR UPDATE OR DELETE ON calendar
FOR EACH ROW EXECUTE FUNCTION audit_calendar_changes();
```

**Quem implementa:** @dev ou @devops via migração Supabase.

**Impacto:** Com isso, Watson pode fazer:
```
SELECT * FROM audit_spent WHERE record_id = '{id}' ORDER BY changed_at
```
E ver a cadeia completa: INSERT → UPDATE(valor) → UPDATE(nome) → DELETE.

---

### 4. Não consigo rastrear qual execução do N8N processou cada mensagem

**Hoje:** Os testes antigos tinham `exec_id` (ID de execução do N8N), mas eu não consigo verificar o que aconteceu dentro daquela execução.

**Solução:** Gravar o `execution_id` do N8N na `log_users_messages`:
```sql
ALTER TABLE log_users_messages ADD COLUMN n8n_execution_id INTEGER;
```

**Quem implementa:** @dev — no workflow N8N, no nó que grava o log, incluir `{{ $execution.id }}`.

---

### 5. Watson deveria pollar em vez de sleep fixo

**Hoje:**
```bash
send_msg "gastei 47 na pizza"
sleep 18  # burro: espera fixo, pode ser muito ou pouco
get_last_ai
```

**Deveria ser:**
```bash
send_msg "gastei 47 na pizza"
LAST_ID=$(get_last_log_id)
# Poll até aparecer novo log
while [ $(get_last_log_id) -eq $LAST_ID ]; do sleep 2; done
get_last_ai
```

**Quem implementa:** Watson (eu mesmo). Posso criar um script em `tools/` do squad.

---

## Checklist: Como conseguir cada informação para auditoria 360°

| Informação | Como consigo hoje | Como deveria conseguir |
|------------|------------------|----------------------|
| Mensagem do user | `log_users_messages.user_message` ✅ | ✅ OK |
| Resposta da IA | `log_users_messages.ai_message` ✅ | ✅ OK |
| Registro financeiro criado | `SELECT * FROM spent WHERE name=X` ✅ | Deveria ter ID na resposta da IA |
| Registro financeiro editado | `SELECT * FROM spent WHERE name=X` ⚠️ | Precisa de `audit_spent` com old/new values |
| Registro financeiro deletado | Contagem antes/depois ⚠️ | Precisa de `audit_spent` com DELETE log |
| Evento criado | `SELECT * FROM calendar WHERE event_name=X` ✅ | Deveria ter ID na resposta da IA |
| Evento editado | `SELECT * FROM calendar WHERE event_name=X` ⚠️ | Precisa de `audit_calendar` |
| Evento deletado | Busca antes/depois ⚠️ | Precisa de `audit_calendar` com DELETE log |
| Execução N8N | Não consigo ❌ | `n8n_execution_id` no log |
| Processamento completo | `sleep 18` (burro) ❌ | Poll por novo log_id |
| Entrega WhatsApp | Não verifico (confiamos) | — |
| Sync Google Calendar | Não verifico (confiamos) | — |

---

## Prioridade de implementação

| # | O que | Esforço | Impacto | Quem |
|---|-------|---------|---------|------|
| 1 | **Audit triggers (spent + calendar)** | Médio (SQL) | ALTO — resolve 80% dos problemas de verificação | @dev |
| 2 | **Poll em vez de sleep no Watson** | Baixo (script) | MÉDIO — testes mais confiáveis e rápidos | Watson |
| 3 | **ID do registro na resposta da IA** | Baixo (N8N) | MÉDIO — rastreabilidade direta | @dev |
| 4 | **n8n_execution_id no log** | Baixo (N8N) | BAIXO — debug mais fácil | @dev |
| 5 | **Prefixo TEST_ nos nomes** | Zero (Watson) | BAIXO — evita conflito com dados reais | Watson |

---

*Relatório gerado por @testador (Watson) — agente de testes DEV-ONLY*
