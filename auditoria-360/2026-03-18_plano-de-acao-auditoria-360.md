# Plano de Ação — Auditoria 360° do Total Assistente

**Data:** 2026-03-18
**Agente:** @testador (Watson)
**Status:** Aprovado para implementação

---

## Contexto

Os testes de hoje revelaram que:
1. **CREATE e DELETE funcionam** e são verificáveis
2. **UPDATE funciona mas é assíncrono** — a IA anuncia antes do banco atualizar
3. Watson verificava cedo demais e concluía que edições falharam (falso negativo)
4. Confirmação em recorrentes é comportamento desejado, não bug
5. `end_event` não atualiza quando `start_event` muda (bug real menor)
6. Categoria na resposta da IA pode divergir do banco (IA diz "Renda Extra", banco grava "Outros")

---

## BLOCO 1: Watson (eu mesmo) — O que eu mudo no meu jeito de testar

### 1.1 — Polling em vez de sleep fixo

**Problema:** Eu uso `sleep 18` e torço pra ter processado. Às vezes checo o log anterior.

**Ação:**
```bash
# ANTES (burro):
send_msg "gastei 47 na pizza"
sleep 18
get_last_ai  # pode pegar resposta antiga

# DEPOIS (inteligente):
LAST_ID=$(get_last_log_id)
send_msg "gastei 47 na pizza"
# Pollar até novo log aparecer (max 45s)
for i in $(seq 1 15); do
  sleep 3
  NEW_ID=$(get_last_log_id)
  if [ "$NEW_ID" -gt "$LAST_ID" ]; then break; fi
done
get_last_ai
```

**Onde implementar:** `squads/testador-n8n/tools/poll-response.sh`
**Esforço:** 30 minutos
**Quem:** Watson

---

### 1.2 — Para edições: esperar DUAS vezes

**Problema:** Edições são assíncronas. A IA responde primeiro, o banco atualiza depois.

**Ação:**
```
1. Enviar mensagem de edição
2. Pollar até resposta da IA aparecer (poll #1)
3. Esperar mais 10-15s para o async completar (poll #2)
4. SÓ ENTÃO verificar o banco
```

**Para DELETE que vem depois de edições:**
```
NÃO deletar imediatamente após editar.
Esperar o async da edição completar, verificar, DEPOIS deletar.
```

**Onde:** No fluxo de teste do Watson
**Esforço:** Ajuste de metodologia
**Quem:** Watson

---

### 1.3 — Prefixo TEST_ nos nomes

**Problema:** Dados de teste se misturam com dados reais/anteriores.

**Ação:** Watson sempre usa nomes com prefixo identificável:
```
"gastei 47 na pizza" → "gastei 47 no teste-pizza-w1"
```

Depois do teste, Watson limpa (deleta) os registros de teste.

**Onde:** Padrão do Watson ao gerar mensagens
**Esforço:** Zero
**Quem:** Watson

---

### 1.4 — Verificar TODOS os campos, não só nome+valor

**Problema:** Eu marquei W2 como "✅" mas a categoria estava errada.

**Ação:** Para cada CREATE/UPDATE, Watson verifica:

**Gastos (`spent`):**
- [ ] `name_spent` = o que a IA disse
- [ ] `value_spent` = o que a IA disse
- [ ] `category_spent` = o que a IA disse ← **aqui é onde diverge**
- [ ] `transaction_type` = saida/entrada correto
- [ ] `type_spent` = classificação coerente
- [ ] `date_spent` = data do dia do teste
- [ ] `fk_user` = user correto

**Eventos (`calendar`):**
- [ ] `event_name` = o que a IA disse
- [ ] `start_event` = data/hora que a IA disse
- [ ] `end_event` = coerente com start (ex: +30min)
- [ ] `is_recurring` + `rrule` = se recorrente, correto
- [ ] `active` = true
- [ ] `connect_google` = true (se user tem Google conectado)
- [ ] `session_event_id_google` = não null (sync Google)
- [ ] `compromisso_tipo` = correto (compromisso/lembrete)

**Onde:** `checklists/auditoria-360-checklist.md` (já criado)
**Quem:** Watson

---

## BLOCO 2: @dev — O que precisa ser implementado no sistema

### 2.1 — Audit triggers no PostgreSQL (PRIORIDADE 1)

**Problema:** Sem histórico de mudanças, é impossível verificar se uma edição realmente aconteceu vs. o valor já era aquele.

**Ação:** Criar tabelas de auditoria + triggers.

```sql
-- ============================
-- AUDIT PARA TABELA SPENT
-- ============================
CREATE TABLE IF NOT EXISTS audit_spent (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL,              -- INSERT, UPDATE, DELETE
  record_id UUID,                    -- id_spent
  old_values JSONB,                  -- estado anterior (UPDATE/DELETE)
  new_values JSONB,                  -- estado novo (INSERT/UPDATE)
  changed_fields TEXT[],             -- quais campos mudaram (UPDATE)
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT DEFAULT 'n8n'          -- quem fez a mudança
);

CREATE OR REPLACE FUNCTION fn_audit_spent()
RETURNS TRIGGER AS $$
DECLARE
  changed TEXT[] := '{}';
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_spent(action, record_id, new_values)
    VALUES ('INSERT', NEW.id_spent, to_jsonb(NEW));
    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    -- Detectar quais campos mudaram
    IF OLD.name_spent IS DISTINCT FROM NEW.name_spent THEN changed := changed || 'name_spent'; END IF;
    IF OLD.value_spent IS DISTINCT FROM NEW.value_spent THEN changed := changed || 'value_spent'; END IF;
    IF OLD.category_spent IS DISTINCT FROM NEW.category_spent THEN changed := changed || 'category_spent'; END IF;
    IF OLD.transaction_type IS DISTINCT FROM NEW.transaction_type THEN changed := changed || 'transaction_type'; END IF;
    IF OLD.type_spent IS DISTINCT FROM NEW.type_spent THEN changed := changed || 'type_spent'; END IF;
    IF OLD.date_spent IS DISTINCT FROM NEW.date_spent THEN changed := changed || 'date_spent'; END IF;

    INSERT INTO audit_spent(action, record_id, old_values, new_values, changed_fields)
    VALUES ('UPDATE', NEW.id_spent, to_jsonb(OLD), to_jsonb(NEW), changed);
    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_spent(action, record_id, old_values)
    VALUES ('DELETE', OLD.id_spent, to_jsonb(OLD));
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_spent
AFTER INSERT OR UPDATE OR DELETE ON spent
FOR EACH ROW EXECUTE FUNCTION fn_audit_spent();


-- ============================
-- AUDIT PARA TABELA CALENDAR
-- ============================
CREATE TABLE IF NOT EXISTS audit_calendar (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  changed_fields TEXT[],
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT DEFAULT 'n8n'
);

CREATE OR REPLACE FUNCTION fn_audit_calendar()
RETURNS TRIGGER AS $$
DECLARE
  changed TEXT[] := '{}';
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_calendar(action, record_id, new_values)
    VALUES ('INSERT', NEW.id, to_jsonb(NEW));
    RETURN NEW;

  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.event_name IS DISTINCT FROM NEW.event_name THEN changed := changed || 'event_name'; END IF;
    IF OLD.start_event IS DISTINCT FROM NEW.start_event THEN changed := changed || 'start_event'; END IF;
    IF OLD.end_event IS DISTINCT FROM NEW.end_event THEN changed := changed || 'end_event'; END IF;
    IF OLD.active IS DISTINCT FROM NEW.active THEN changed := changed || 'active'; END IF;
    IF OLD.is_recurring IS DISTINCT FROM NEW.is_recurring THEN changed := changed || 'is_recurring'; END IF;
    IF OLD.rrule IS DISTINCT FROM NEW.rrule THEN changed := changed || 'rrule'; END IF;

    INSERT INTO audit_calendar(action, record_id, old_values, new_values, changed_fields)
    VALUES ('UPDATE', NEW.id, to_jsonb(OLD), to_jsonb(NEW), changed);
    RETURN NEW;

  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_calendar(action, record_id, old_values)
    VALUES ('DELETE', OLD.id, to_jsonb(OLD));
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_audit_calendar
AFTER INSERT OR UPDATE OR DELETE ON calendar
FOR EACH ROW EXECUTE FUNCTION fn_audit_calendar();
```

**RLS:** As tabelas de audit devem ter SELECT liberado para service_role (Watson usa service_role).

**Impacto:** Com isso, Watson pode verificar:
```
SELECT * FROM audit_spent
WHERE record_id = '{id_do_gasto}'
ORDER BY changed_at;
```
E ver a cadeia: INSERT → UPDATE(valor) → UPDATE(nome) → DELETE.

**Esforço:** 1-2 horas (criar migração, rodar, testar)
**Quem:** @dev ou direto no Supabase SQL Editor

---

### 2.2 — Corrigir `end_event` ao mover evento

**Problema confirmado:** Quando o `start_event` é alterado, o `end_event` fica com a data antiga.

```
Consulta Médica:
  start_event: 2026-03-27T14:00  ← movido corretamente
  end_event:   2026-03-25T14:30  ← ficou no dia 25 (bug)
```

**Ação:** No workflow de edição de eventos, ao alterar `start_event`, recalcular `end_event` mantendo a mesma duração.

```
novo_end = novo_start + (end_original - start_original)
```

**Esforço:** 30 minutos (ajuste no workflow N8N)
**Quem:** @dev

---

### 2.3 — Consistência de categoria entre IA e banco

**Problema:** A IA diz "Renda Extra" mas o banco grava "Outros".

**Investigar:** O classificador de categoria no workflow N8N pode ter uma lista de categorias diferente do que a IA responde ao usuário.

**Ação:** Alinhar as categorias entre o prompt da IA e a lógica de gravação no banco. A IA deve dizer ao user EXATAMENTE a categoria que foi salva.

**Esforço:** 1 hora (investigar workflow + ajustar prompt)
**Quem:** @dev

---

### 2.4 — Adicionar `n8n_execution_id` no log (OPCIONAL)

**Problema:** Não consigo rastrear qual execução do N8N processou cada mensagem.

**Ação:** No workflow, no nó que grava em `log_users_messages`, adicionar:
```
n8n_execution_id: {{ $execution.id }}
```

E na tabela:
```sql
ALTER TABLE log_users_messages ADD COLUMN n8n_execution_id INTEGER;
```

**Esforço:** 30 minutos
**Quem:** @dev

---

## BLOCO 3: Ordem de execução

```
SEMANA 1 (imediato):
├── Watson: Implementar polling (tools/poll-response.sh)
├── Watson: Ajustar metodologia para edições async
├── Watson: Usar prefixo TEST_ nos nomes
└── Watson: Verificar todos os campos (checklist 360°)

SEMANA 1 (junto):
├── @dev: Criar audit triggers (spent + calendar) ← PRIORIDADE 1
└── @dev: Corrigir end_event ao mover evento

SEMANA 2:
├── @dev: Investigar/corrigir divergência de categoria
├── @dev: Adicionar n8n_execution_id no log (opcional)
└── Watson: Rodar bateria completa com nova metodologia

SEMANA 3:
└── Watson: Bateria de regressão automatizada com audit trail
```

---

## Como fica o fluxo de teste DEPOIS dessas mudanças

```
1. SNAPSHOT ANTES
   ├── SELECT * FROM spent WHERE fk_user = X (contar + salvar estado)
   ├── SELECT * FROM calendar WHERE user_id = X (contar + salvar estado)
   └── Registrar último log_id

2. ENVIAR MENSAGEM
   ├── POST webhook dev
   └── POLLAR log_users_messages até novo log_id aparecer

3. VERIFICAR RESPOSTA DA IA
   └── Capturar ai_message do novo log

4. ESPERAR ASYNC (para edições)
   └── Pollar audit_spent/audit_calendar até action aparecer (max 30s)

5. VERIFICAR BANCO
   ├── SELECT * FROM spent (comparar com ANTES)
   ├── SELECT * FROM calendar (comparar com ANTES)
   ├── SELECT * FROM audit_spent WHERE record_id = X (ver cadeia)
   └── Cruzar TODOS os campos (checklist 360°)

6. GERAR RELATÓRIO
   └── .md com evidências de cada verificação
```

---

## Bugs reais confirmados (não falsos negativos)

| Bug | Severidade | Status |
|-----|-----------|--------|
| `end_event` não atualiza ao mover `start_event` | MÉDIO | A corrigir |
| Categoria IA ≠ categoria banco (ex: "Renda Extra" vs "Outros") | MÉDIO | A investigar |
| `log_total` não registra `transacao_criada` durante testes | BAIXO | A investigar |

---

*Plano gerado por @testador (Watson) — agente de testes DEV-ONLY*
