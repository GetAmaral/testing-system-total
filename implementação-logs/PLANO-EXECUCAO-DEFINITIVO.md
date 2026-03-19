# PLANO DE EXECUCAO DEFINITIVO — Sistema de Logs

**Data:** 2026-03-19
**Tempo total estimado:** 2h30
**Risco geral:** BAIXO (todos os nós são paralelos com continueOnFail)

---

## DADOS DE REFERENCIA (usar em todo o plano)

```
SUPABASE_URL       = https://ldbdtakddxznfridsarn.supabase.co
SUPABASE_CRED_ID   = kQkN5PrZm2GihQfS
SUPABASE_CRED_NAME = Total Supabase

N8N_URL            = https://n8n.totalassistente.com.br
WEBHOOK_LOG_URL    = https://n8n.totalassistente.com.br/webhook/execution-log

WORKFLOWS:
  Main      = 9WDlyel5xRCLAvtH
  Premium   = tyJ3YAAtSg1UurFj
  Standard  = c8gtSmh1BPzZXbJa
  Financeiro = eYWjnmvP8LQxY87g
  Lembretes = sjDpjKqtwLk7ycki
  Calendar  = ZZbMdcuCKx0fM712
  Report    = S2QgrsN6uteyB04E
  Service24h = GNdoIS2zxGBa4CW0
```

---

# TIME BLOCKING

## BLOCO 1 — Supabase (15 min)

### 1.1 Criar tabela execution_log (5 min)

**Onde:** Supabase Dashboard → SQL Editor
**Ação:** Copiar e colar o SQL abaixo INTEIRO e clicar Run

```sql
-- ============================================================
-- COPIAR TUDO DE UMA VEZ — de aqui até o final do bloco SQL
-- ============================================================

CREATE TABLE IF NOT EXISTS public.execution_log (
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id         TEXT,
    user_phone      TEXT NOT NULL,
    user_name       TEXT,
    user_email      TEXT,
    user_plan       TEXT,
    user_message    TEXT,
    message_type    TEXT DEFAULT 'text',
    message_id      TEXT,
    transcription_text TEXT,
    summary_text    TEXT,
    branch          TEXT,
    ai_message      TEXT,
    ai_action       TEXT,
    ai_tools_called JSONB,
    ai_full_response JSONB,
    action_type     TEXT,
    action_input    JSONB,
    action_output   JSONB,
    action_success  BOOLEAN,
    extracted_data  JSONB,
    source_workflow TEXT NOT NULL,
    event_type      TEXT NOT NULL,
    routed_to       TEXT,
    execution_id    TEXT,
    duration_ms     INTEGER,
    error_message   TEXT,
    metadata        JSONB DEFAULT '{}'::jsonb,
    severity        TEXT DEFAULT 'info'
                    CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),
    message_timestamp TIMESTAMPTZ,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_execution_log_user_phone ON public.execution_log (user_phone);
CREATE INDEX idx_execution_log_user_id ON public.execution_log (user_id);
CREATE INDEX idx_execution_log_created_at ON public.execution_log (created_at DESC);
CREATE INDEX idx_execution_log_event_type ON public.execution_log (event_type);
CREATE INDEX idx_execution_log_source_workflow ON public.execution_log (source_workflow);
CREATE INDEX idx_execution_log_branch ON public.execution_log (branch);
CREATE INDEX idx_execution_log_action_type ON public.execution_log (action_type);
CREATE INDEX idx_execution_log_message_type ON public.execution_log (message_type);
CREATE INDEX idx_execution_log_user_phone_created ON public.execution_log (user_phone, created_at DESC);
CREATE INDEX idx_execution_log_user_event ON public.execution_log (user_phone, event_type, created_at DESC);
CREATE INDEX idx_execution_log_severity ON public.execution_log (severity) WHERE severity IN ('error', 'critical');

ALTER TABLE public.execution_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Bloquear acesso publico ao execution_log"
    ON public.execution_log FOR ALL USING (false) WITH CHECK (false);

CREATE POLICY "Service role full access to execution_log"
    ON public.execution_log FOR ALL TO service_role USING (true) WITH CHECK (true);

CREATE OR REPLACE FUNCTION prevent_execution_log_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'execution_log is append-only. UPDATE and DELETE are not allowed.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_execution_log_immutable
  BEFORE UPDATE OR DELETE ON public.execution_log
  FOR EACH ROW EXECUTE FUNCTION prevent_execution_log_modification();

CREATE OR REPLACE FUNCTION fn_execution_log_resumo(
  p_start_date TIMESTAMPTZ, p_end_date TIMESTAMPTZ
) RETURNS JSON AS $$
DECLARE result JSON;
BEGIN
  SELECT json_build_object(
    'total_executions', COUNT(*),
    'total_errors', COUNT(*) FILTER (WHERE error_message IS NOT NULL),
    'total_actions', COUNT(*) FILTER (WHERE event_type = 'action_executed'),
    'total_interactions', COUNT(*) FILTER (WHERE event_type = 'interaction_complete'),
    'total_deletes', COUNT(*) FILTER (WHERE action_type LIKE 'excluir%'),
    'success_rate', ROUND(100.0 * COUNT(*) FILTER (WHERE action_success = true OR action_success IS NULL) / NULLIF(COUNT(*), 0), 1),
    'unique_users', COUNT(DISTINCT user_phone),
    'by_workflow', (SELECT json_object_agg(source_workflow, cnt) FROM (SELECT source_workflow, COUNT(*) as cnt FROM execution_log WHERE created_at BETWEEN p_start_date AND p_end_date GROUP BY source_workflow) sub),
    'by_event_type', (SELECT json_object_agg(event_type, cnt) FROM (SELECT event_type, COUNT(*) as cnt FROM execution_log WHERE created_at BETWEEN p_start_date AND p_end_date GROUP BY event_type) sub),
    'by_severity', (SELECT json_object_agg(severity, cnt) FROM (SELECT severity, COUNT(*) as cnt FROM execution_log WHERE created_at BETWEEN p_start_date AND p_end_date GROUP BY severity) sub)
  ) INTO result FROM execution_log WHERE created_at BETWEEN p_start_date AND p_end_date;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_execution_log_user_timeline(
  p_user_phone TEXT,
  p_start_date TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
  p_end_date TIMESTAMPTZ DEFAULT NOW()
) RETURNS TABLE (
  id UUID, created_at TIMESTAMPTZ, event_type TEXT, source_workflow TEXT,
  user_message TEXT, ai_message TEXT, branch TEXT, ai_action TEXT,
  action_type TEXT, action_success BOOLEAN, error_message TEXT, severity TEXT,
  message_type TEXT, transcription_text TEXT, metadata JSONB
) AS $$
BEGIN
  RETURN QUERY SELECT e.id, e.created_at, e.event_type, e.source_workflow,
    e.user_message, e.ai_message, e.branch, e.ai_action, e.action_type,
    e.action_success, e.error_message, e.severity, e.message_type,
    e.transcription_text, e.metadata
  FROM execution_log e
  WHERE e.user_phone = p_user_phone AND e.created_at BETWEEN p_start_date AND p_end_date
  ORDER BY e.created_at ASC;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE public.execution_log IS 'Log centralizado de execucao para auditoria — append-only.';
```

### 1.2 Testar tabela (5 min)

**Onde:** Supabase Dashboard → SQL Editor

```sql
-- Teste de INSERT (deve funcionar)
INSERT INTO execution_log (user_phone, source_workflow, event_type, severity)
VALUES ('5543999999999', 'test', 'classification', 'info');

-- Verificar
SELECT * FROM execution_log WHERE source_workflow = 'test';

-- Teste de UPDATE (deve DAR ERRO — isso é o esperado!)
UPDATE execution_log SET severity = 'error' WHERE source_workflow = 'test';
-- Esperado: "execution_log is append-only. UPDATE and DELETE are not allowed."

-- Teste de DELETE (deve DAR ERRO — isso é o esperado!)
DELETE FROM execution_log WHERE source_workflow = 'test';
-- Esperado: mesmo erro acima
```

**Se os dois últimos derem erro, PERFEITO — a imutabilidade está funcionando.**

### 1.3 Limpar teste (2 min)

Para limpar o registro de teste, precisamos desabilitar o trigger temporariamente:

```sql
-- Desabilitar trigger temporariamente para limpar teste
ALTER TABLE execution_log DISABLE TRIGGER tr_execution_log_immutable;
DELETE FROM execution_log WHERE source_workflow = 'test';
ALTER TABLE execution_log ENABLE TRIGGER tr_execution_log_immutable;
```

### 1.4 Testar RPC functions (3 min)

```sql
-- Teste resumo (deve retornar JSON com zeros)
SELECT fn_execution_log_resumo(NOW() - INTERVAL '7 days', NOW());

-- Teste timeline (deve retornar 0 rows)
SELECT * FROM fn_execution_log_user_timeline('5543999999999');
```

---

### CHECKPOINT 1: Tabela OK?

- [ ] Tabela `execution_log` aparece no Table Editor
- [ ] INSERT funciona
- [ ] UPDATE dá erro (append-only)
- [ ] DELETE dá erro (append-only)
- [ ] RPC functions retornam sem erro

**Se algo falhou:** Ver seção TROUBLESHOOTING no final.

---

## BLOCO 2 — Workflow de Log no N8N (20 min)

### 2.1 Criar novo workflow (10 min)

**Onde:** N8N → + New Workflow → nome: `Execution Log - Total Assistente`

**Criar 4 nós na seguinte ordem:**

#### Nó 1: Webhook Trigger

- Tipo: `Webhook`
- HTTP Method: `POST`
- Path: `execution-log`
- Response Mode: `Respond to Webhook`
- Options: deixar padrão

#### Nó 2: Validar e Normalizar (Code)

- Tipo: `Code`
- Language: JavaScript
- Copiar e colar este código:

```javascript
const body = $input.first().json.body || $input.first().json;

if (!body.user_phone) throw new Error('Campo obrigatorio ausente: user_phone');
if (!body.source_workflow) throw new Error('Campo obrigatorio ausente: source_workflow');
if (!body.event_type) throw new Error('Campo obrigatorio ausente: event_type');

const normalizePhone = (phone) => {
  if (!phone) return null;
  return phone.toString().replace(/[^0-9]/g, '');
};

const parseIfString = (val) => {
  if (!val) return null;
  if (typeof val === 'string') {
    try { return JSON.parse(val); } catch { return val; }
  }
  return val;
};

// Determinar severity automaticamente
let severity = body.severity || 'info';
if (body.error_message) severity = 'error';
if (body.action_type && body.action_type.startsWith('excluir')) severity = 'warning';

return { json: {
  user_id: body.user_id || null,
  user_phone: normalizePhone(body.user_phone),
  user_name: body.user_name || null,
  user_email: body.user_email || null,
  user_plan: body.user_plan || null,
  user_message: body.user_message || null,
  message_type: body.message_type || 'text',
  message_id: body.message_id || null,
  transcription_text: body.transcription_text || null,
  summary_text: body.summary_text || null,
  branch: body.branch || null,
  ai_message: body.ai_message || null,
  ai_action: body.ai_action || null,
  ai_tools_called: parseIfString(body.ai_tools_called),
  ai_full_response: parseIfString(body.ai_full_response),
  action_type: body.action_type || null,
  action_input: parseIfString(body.action_input),
  action_output: parseIfString(body.action_output),
  action_success: body.action_success != null ? body.action_success : null,
  extracted_data: parseIfString(body.extracted_data),
  source_workflow: body.source_workflow,
  event_type: body.event_type,
  routed_to: body.routed_to || null,
  execution_id: body.execution_id || null,
  duration_ms: body.duration_ms || null,
  error_message: body.error_message || null,
  metadata: parseIfString(body.metadata) || {},
  severity: severity,
  message_timestamp: body.message_timestamp || null
}};
```

- Settings → On Error: **Continue Using Error Output**

#### Nó 3: Salvar execution_log (Supabase)

- Tipo: `Supabase`
- Operation: `Create a Row`
- Table: `execution_log`
- Credential: **Total Supabase** (id: kQkN5PrZm2GihQfS)
- Columns to Send → Auto-Map Input Data: **ON**
- Settings → On Error: **Continue Using Error Output**

#### Nó 4: Responder OK (Respond to Webhook)

- Tipo: `Respond to Webhook`
- Respond With: `JSON`
- Response Body:

```
={{ JSON.stringify({ success: true, id: $json.id }) }}
```

- Response Code: `200`

#### Nó 5: Responder Erro (Respond to Webhook)

- Tipo: `Respond to Webhook`
- Respond With: `JSON`
- Response Body:

```
={{ JSON.stringify({ success: false, error: $json.message || 'Erro ao salvar log' }) }}
```

- Response Code: `400`

#### Conexões:

```
[Webhook Trigger] → [Validar e Normalizar] → [Salvar execution_log] → [Responder OK]
                                           ↘ (Error Output) → [Responder Erro]
                   [Salvar execution_log]  ↘ (Error Output) → [Responder Erro]
```

### 2.2 Ativar e testar (5 min)

1. **Salvar** o workflow
2. **Ativar** (toggle ON no canto superior direito)
3. Testar via terminal:

```bash
curl -X POST https://n8n.totalassistente.com.br/webhook/execution-log \
  -H "Content-Type: application/json" \
  -d '{
    "user_phone": "5543999999999",
    "user_name": "Teste Manual",
    "user_message": "Oi, isso e um teste",
    "ai_message": "Ola! Como posso ajudar?",
    "source_workflow": "test",
    "event_type": "interaction_complete",
    "branch": "padrao"
  }'
```

Resposta esperada: `{"success":true,"id":"uuid-aqui"}`

4. Verificar no Supabase:

```sql
SELECT * FROM execution_log WHERE source_workflow = 'test';
```

5. Limpar teste:

```sql
ALTER TABLE execution_log DISABLE TRIGGER tr_execution_log_immutable;
DELETE FROM execution_log WHERE source_workflow = 'test';
ALTER TABLE execution_log ENABLE TRIGGER tr_execution_log_immutable;
```

### 2.3 Testar com campos JSONB (5 min)

```bash
curl -X POST https://n8n.totalassistente.com.br/webhook/execution-log \
  -H "Content-Type: application/json" \
  -d '{
    "user_phone": "5543999999999",
    "user_id": "abc-123",
    "user_name": "Teste JSONB",
    "source_workflow": "test",
    "event_type": "action_executed",
    "action_type": "registrar_financeiro",
    "action_input": {"nome_gasto": "Almoco", "valor_gasto": 50, "categoria": "Alimentacao"},
    "action_success": true,
    "ai_tools_called": [{"name": "registrar_financeiros", "args": {"valor": 50}}]
  }'
```

Verificar se os campos JSONB foram salvos corretamente no Supabase.

---

### CHECKPOINT 2: Workflow de Log OK?

- [ ] Workflow criado e ativo
- [ ] POST retorna `{"success":true}`
- [ ] Dados aparecem na tabela `execution_log`
- [ ] Campos JSONB salvos corretamente
- [ ] Erro retorna status 400

**Se o POST retornar 404:** O workflow não está ativo ou o path está errado.
**Se retornar 500:** Verificar credencial Supabase no nó.

---

## BLOCO 3 — Nós de Log nos Workflows (1h30)

### REGRA PARA TODOS OS NÓS:

Cada nó de log segue o MESMO padrão:
1. Tipo: **HTTP Request**
2. Method: **POST**
3. URL: `https://n8n.totalassistente.com.br/webhook/execution-log`
4. Body Type: **JSON**
5. Specify Body: **Using JSON**
6. Settings → On Error: **Continue** (OBRIGATÓRIO!)
7. Timeout: **5000ms**
8. Posição: **PARALELO** (segunda saída do nó anterior, NÃO em série)

### 3.1 — Main - Total Assistente (15 min)

**Backup:** Exportar workflow como JSON antes de editar.

#### Nó LOG-M1: Transcrição de Áudio

**Após:** Nó `Redis` (SET transcricao:{wa_id})
**Conexão:** Saída paralela do Redis (não substituir conexão existente, ADICIONAR segunda saída)

JSON Body:
```
={{ JSON.stringify({ user_phone: $('trigger-whatsapp').item.json.entry[0].changes[0].value.contacts[0].wa_id, user_id: $('setar_user').item.json.user_id || null, user_name: $('setar_user').item.json.user_name || null, user_message: '[AUDIO]', message_type: 'audio', transcription_text: $('Transcribe a recording').item.json.text, source_workflow: 'main', event_type: 'transcription', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-M2: Resumo de Áudio

**Após:** Nó `Message a model` (resumo)
**Conexão:** Saída paralela

JSON Body:
```
={{ JSON.stringify({ user_phone: $('trigger-whatsapp').item.json.entry[0].changes[0].value.contacts[0].wa_id, user_id: $('setar_user').item.json.user_id || null, user_name: $('setar_user').item.json.user_name || null, transcription_text: $('Redis1').item.json.data || null, summary_text: $('Message a model').item.json.message.content, source_workflow: 'main', event_type: 'audio_summary', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-M3: Roteamento Premium/Standard

**Após:** Nó `Premium User` (HTTP Request)
**Conexão:** Saída paralela

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone, user_id: $('setar_user').item.json.user_id, user_name: $('setar_user').item.json.user_name, user_plan: $('If3').item.json.plan_type || 'unknown', user_message: $('setar_user').item.json.conversation, message_type: $('setar_user').item.json.messageType || 'text', message_id: $('setar_user').item.json.messageId || null, source_workflow: 'main', event_type: 'message_routed', routed_to: $('If3').item.json.plan_type === 'premium' ? 'premium' : 'standard', message_timestamp: new Date().toISOString() }) }}
```

**Salvar workflow.**

---

### 3.2 — Premium - Fix Conflito v2 (30 min)

**Backup:** Exportar workflow como JSON antes de editar.

#### Nó LOG-P1: Classificação de Intent

**Após:** Nó `Escolher Branch`
**Conexão:** Saída paralela (manter conexão para Switch - Branches1)

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_message: $('Merge1').item.json.mensagem || null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output, source_workflow: 'premium', event_type: 'classification', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-P2: Resposta IA Completa

**Após:** Nó `Code in JavaScript`
**Conexão:** Saída paralela (manter conexão para Switch2)

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_plan: 'premium', user_message: $('Merge1').item.json.mensagem || null, ai_message: $json.parsed_output ? $json.parsed_output.mensagem : null, ai_action: $json.parsed_output ? $json.parsed_output.acao : null, ai_tools_called: $json.parsed_output ? $json.parsed_output.tool : null, ai_full_response: $json.parsed_output || null, source_workflow: 'premium', event_type: 'ai_response', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-P3: Consolidação Final

**Após:** Nó `Create a row1` (log_users_messages existente)
**Conexão:** Saída sequencial (após o Create a row1)

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_email: $('Get a row').item.json.email || null, user_plan: 'premium', user_message: $('Merge1').item.json.mensagem || null, message_type: $('setar_user').item.json.messageType || $('Evolution API').item.json.messageType || 'text', ai_message: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.mensagem : null, ai_action: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.acao : null, ai_tools_called: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.tool : null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output || null, source_workflow: 'premium', event_type: 'interaction_complete', message_timestamp: new Date().toISOString() }) }}
```

**Salvar workflow.**

---

### 3.3 — Standard - User Standard - Total (30 min)

**Backup:** Exportar workflow como JSON antes de editar.

#### Nó LOG-S1: Classificação de Intent

**Mesmo padrão do LOG-P1**, mas com `source_workflow: 'standard'`.

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_message: $('Merge1').item.json.mensagem || null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output, source_workflow: 'standard', event_type: 'classification', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-S2: Resposta IA Completa

**Mesmo padrão do LOG-P2**, mas com `source_workflow: 'standard'` e `user_plan: 'standard'`.

JSON Body:
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_plan: 'standard', user_message: $('Merge1').item.json.mensagem || null, ai_message: $json.parsed_output ? $json.parsed_output.mensagem : null, ai_action: $json.parsed_output ? $json.parsed_output.acao : null, ai_tools_called: $json.parsed_output ? $json.parsed_output.tool : null, ai_full_response: $json.parsed_output || null, source_workflow: 'standard', event_type: 'ai_response', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-S3: Consolidação Final (CRITICO — hoje não existe NENHUM log no Standard!)

**Onde:** Identificar TODOS os pontos finais de envio de mensagem no Standard. Os principais são:
- `HTTP Request — send text`
- `HTTP Request — Basic Template`
- `HTTP Request — Basic Template1`
- `Send message`
- `Send message1`
- `Send message2`

**Após CADA um desses nós**, adicionar um nó de log com a mesma configuração.

JSON Body (copiar para cada nó de envio):
```
={{ JSON.stringify({ user_phone: $('setar_user').item.json.user_phone || $('Evolution API').item.json.user_phone, user_id: $('setar_user').item.json.user_id || $('Evolution API').item.json.user_id, user_name: $('setar_user').item.json.user_name || $('Evolution API').item.json.user_name, user_plan: 'standard', user_message: $('Merge1').item.json.mensagem || null, message_type: $('setar_user').item.json.messageType || $('Evolution API').item.json.messageType || 'text', ai_message: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.mensagem : null, ai_action: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.acao : null, ai_tools_called: $('Code in JavaScript').item.json.parsed_output ? $('Code in JavaScript').item.json.parsed_output.tool : null, branch: $('Escolher Branch').item.json.text || $('Escolher Branch').item.json.output || null, source_workflow: 'standard', event_type: 'interaction_complete', message_timestamp: new Date().toISOString() }) }}
```

**Salvar workflow.**

---

### 3.4 — Financeiro - Total (10 min)

**Backup:** Exportar workflow como JSON antes de editar.

#### Nó LOG-F1: Registrar Gasto/Receita

**Após:** Nó `Create a row` (insert no spent)
**Conexão:** Saída paralela

JSON Body:
```
={{ JSON.stringify({ user_phone: $json.user_phone || $('setar_campos').item.json.user_phone || null, user_id: $json.fk_user || $('setar_campos').item.json.user_id || null, action_type: 'registrar_financeiro', action_input: { nome: $json.name_spent, valor: $json.value_spent, categoria: $json.category_spent, data: $json.date_spent, tipo: $json.entra_sai_gasto }, action_success: true, source_workflow: 'financeiro', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-F2: Editar Gasto

**Após:** Nó `Update a row`
**Conexão:** Saída paralela

JSON Body:
```
={{ JSON.stringify({ user_phone: $json.user_phone || null, user_id: $json.fk_user || $json.id_user || null, action_type: 'editar_financeiro', action_input: { id_gasto: $json.id_spent, campos: { nome: $json.name_spent, valor: $json.value_spent, categoria: $json.category_spent, data: $json.date_spent } }, action_success: true, severity: 'info', source_workflow: 'financeiro', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-F3: Excluir Gasto (P0 CRITICO)

**Após:** Nó `Delete a row`
**Conexão:** Saída paralela

JSON Body:
```
={{ JSON.stringify({ user_phone: $json.user_phone || null, user_id: $json.fk_user || $json.id_user || null, action_type: 'excluir_financeiro', action_input: { id_gasto: $json.id_spent || $json.id_gasto }, action_success: true, severity: 'warning', source_workflow: 'financeiro', event_type: 'action_executed', metadata: { operation: 'DELETE', table: 'spent', irreversible: true }, message_timestamp: new Date().toISOString() }) }}
```

**Salvar workflow.**

---

### 3.5 — Calendar WebHooks (10 min)

**Backup:** Exportar workflow como JSON antes de editar.

#### Nó LOG-C1: Editar Evento

**Após:** Nó `Update a row1`

JSON Body:
```
={{ JSON.stringify({ user_id: $json.user_id || null, user_phone: null, action_type: 'editar_evento', action_input: { event_name: $json.event_name, start: $json.start_event, end: $json.end_event }, action_success: true, source_workflow: 'calendar', event_type: 'action_executed', message_timestamp: new Date().toISOString() }) }}
```

#### Nó LOG-C2: Excluir Evento (P0 CRITICO)

**Após:** Nós `delete_supabase` e `delete_supabase1` (adicionar em AMBOS)

JSON Body:
```
={{ JSON.stringify({ user_id: $json.user_id || null, user_phone: null, action_type: 'excluir_evento', action_success: true, severity: 'warning', source_workflow: 'calendar', event_type: 'action_executed', metadata: { operation: 'DELETE', table: 'calendar', irreversible: true }, message_timestamp: new Date().toISOString() }) }}
```

**Salvar workflow.**

---

## BLOCO 4 — Validação End-to-End (15 min)

### 4.1 Teste com mensagem real (5 min)

Enviar pelo WhatsApp de teste uma mensagem como `Gastei 30 no uber`.

Esperar ~30 segundos e verificar no Supabase:

```sql
SELECT event_type, source_workflow, branch, ai_action, ai_message,
       action_type, severity, created_at
FROM execution_log
ORDER BY created_at DESC
LIMIT 20;
```

**Esperado:** 3-5 registros para essa mensagem:
1. `message_routed` (source: main)
2. `classification` (source: premium, branch: criar_gasto)
3. `ai_response` (source: premium, ai_action: registrar_gasto)
4. `action_executed` (source: financeiro, action_type: registrar_financeiro)
5. `interaction_complete` (source: premium)

### 4.2 Verificar separação por usuário (3 min)

```sql
-- Buscar por telefone
SELECT event_type, user_message, ai_message, created_at
FROM execution_log
WHERE user_phone = '554391936205'
ORDER BY created_at DESC
LIMIT 10;

-- Contagem por usuário
SELECT user_phone, user_name, COUNT(*) as total_events
FROM execution_log
GROUP BY user_phone, user_name
ORDER BY total_events DESC;
```

### 4.3 Verificar cobertura de workflows (3 min)

```sql
SELECT source_workflow, COUNT(*) as total,
       COUNT(*) FILTER (WHERE error_message IS NOT NULL) as errors
FROM execution_log
GROUP BY source_workflow
ORDER BY total DESC;
```

### 4.4 Testar RPC do dashboard (2 min)

```sql
SELECT fn_execution_log_resumo(NOW() - INTERVAL '1 hour', NOW());
SELECT * FROM fn_execution_log_user_timeline('554391936205');
```

### 4.5 Teste de áudio (2 min)

Enviar um áudio pelo WhatsApp e verificar:

```sql
SELECT event_type, transcription_text, summary_text, created_at
FROM execution_log
WHERE message_type = 'audio' OR event_type IN ('transcription', 'audio_summary')
ORDER BY created_at DESC
LIMIT 5;
```

---

### CHECKPOINT FINAL

- [ ] Tabela `execution_log` funcionando (append-only)
- [ ] Workflow de log ativo e recebendo POSTs
- [ ] Main logando: transcrição, resumo, roteamento
- [ ] Premium logando: classificação, IA, consolidação
- [ ] Standard logando: classificação, IA, consolidação
- [ ] Financeiro logando: registrar, editar, excluir
- [ ] Calendar logando: editar, excluir
- [ ] Dados separados por user_phone
- [ ] RPC functions retornando dados corretos
- [ ] Nenhum impacto no fluxo principal (mensagens continuam chegando normalmente)

---

# POSSIVEIS PROBLEMAS E COMO EVITAR

## Problema 1: Nó de log causa erro e interrompe o fluxo

**Risco:** ALTO se esquecer de configurar `continueOnFail`
**Causa:** Nó de log falha (URL errada, timeout, campo inválido) e bloqueia o workflow
**Como evitar:**
- SEMPRE marcar `continueOnFail: true` em Settings de CADA nó de log
- SEMPRE conectar em PARALELO, não em SÉRIE (segunda saída do nó anterior)
- Definir timeout de 5000ms para não atrasar

**Como detectar:**
- Se um usuário enviar mensagem e NÃO receber resposta, verificar imediatamente as execuções do workflow no N8N
- Se o nó de log estiver em vermelho, o erro está nele

**Como corrigir:**
- Abrir o workflow → clicar no nó de log em vermelho → Settings → On Error → Continue
- Se o erro persistir, desconectar o nó temporariamente (não deletar, apenas desconectar)

## Problema 2: Referência a nó inválida (expressão $('nome_do_no'))

**Risco:** ALTO nos primeiros testes
**Causa:** Os nomes dos nós nos JSONs acima assumem nomes EXATOS como `setar_user`, `Merge1`, `Escolher Branch`, `Code in JavaScript`. Se o nó foi renomeado no workflow real, a expressão retorna `undefined`.
**Como evitar:**
- Antes de colar o JSON Body, verificar o nome EXATO do nó no workflow
- Clicar no nó e conferir o título na parte superior
- Se diferir, ajustar a expressão `$('nome_correto')`

**Como detectar:**
- Dados chegam ao `execution_log` com campos `null` que deveriam ter valor
- Verificar: `SELECT * FROM execution_log WHERE user_phone IS NULL AND event_type != 'action_executed';`

**Como corrigir:**
- Abrir o nó de log → editar a expressão → corrigir o nome do nó referenciado

## Problema 3: Webhook URL incorreta

**Risco:** MEDIO
**Causa:** A URL `https://n8n.totalassistente.com.br/webhook/execution-log` pode variar dependendo da configuração do N8N
**Como evitar:**
- Após ativar o workflow, clicar no nó Webhook Trigger → aba "Test" → copiar a URL de produção exata
- Usar ESSA URL em todos os nós de log

**Como detectar:**
- curl retorna 404
- Nós de log ficam vermelhos com "Request failed with status code 404"

**Como corrigir:**
- Copiar a URL correta do Webhook Trigger e atualizar todos os nós

## Problema 4: Campos JSONB salvos como string em vez de objeto

**Risco:** BAIXO
**Causa:** O Supabase espera JSONB mas recebe string não-parseada
**Como evitar:**
- O nó `Validar e Normalizar` já faz `parseIfString()` em todos os campos JSONB
- Usar `JSON.stringify()` ao enviar e o nó de validação parseia antes de salvar

**Como detectar:**
- No Supabase, se o campo `ai_tools_called` aparecer como `"[{...}]"` (string com aspas) em vez de `[{...}]` (array)

**Como corrigir:**
- Verificar se o nó `Salvar execution_log` está usando Auto-Map Input Data: ON

## Problema 5: Volume alto de logs causa lentidão

**Risco:** MUITO BAIXO (estimativa: ~700 inserts/dia)
**Causa:** Muitos índices ou tabela muito grande
**Como evitar:**
- Os índices criados são necessários — não remover
- Se volume crescer muito (>10.000/dia), considerar particionamento

**Como detectar:**
- Queries do dashboard demorando mais de 2 segundos
- `SELECT pg_size_pretty(pg_total_relation_size('execution_log'));` — se > 1GB

**Como corrigir:**
- Implementar particionamento por mês (ver doc 09-BOAS-PRATICAS)
- Ou arquivar logs antigos (>90 dias)

## Problema 6: Trigger de imutabilidade impede correção de dados

**Risco:** BAIXO (só acontece se precisar corrigir um log)
**Causa:** O trigger bloqueia UPDATE e DELETE, inclusive do admin
**Como evitar:**
- Não é evitável — é intencional (boa prática de auditoria)

**Como corrigir (quando necessário):**
```sql
-- Desabilitar temporariamente para correção
ALTER TABLE execution_log DISABLE TRIGGER tr_execution_log_immutable;

-- Fazer a correção
DELETE FROM execution_log WHERE id = 'uuid-especifico';

-- Reabilitar IMEDIATAMENTE
ALTER TABLE execution_log ENABLE TRIGGER tr_execution_log_immutable;
```

## Problema 7: Standard continua sem logar (nó não conectado corretamente)

**Risco:** ALTO — este é o gap mais crítico que estamos resolvendo
**Causa:** No Standard existem MUITOS pontos finais de envio (Send message, HTTP Request — send text, etc.) e é fácil esquecer de conectar um
**Como evitar:**
- Após adicionar os nós, enviar 5 mensagens de teste variadas pelo Standard
- Verificar se TODAS geraram logs

**Como detectar:**
```sql
-- Se retornar 0, o Standard NÃO está logando!
SELECT COUNT(*) FROM execution_log WHERE source_workflow = 'standard';
```

**Como corrigir:**
- Abrir o workflow Standard
- Verificar que CADA nó de envio final tem uma saída conectada ao nó de log
- Os pontos finais são: Send message, Send message1, Send message2, HTTP Request — send text, HTTP Request — Basic Template, HTTP Request — Basic Template1

---

# ROLLBACK (se algo der muito errado)

**Nível 1 — Desativar logs (30 segundos):**
- N8N → Workflow "Execution Log" → Toggle OFF
- Resultado: Nós de log nos workflows vão falhar silenciosamente (continueOnFail), zero impacto

**Nível 2 — Remover nós de log (5 min por workflow):**
- Abrir cada workflow → deletar os nós "LOG: *" → salvar
- Os nós originais NÃO foram modificados, então tudo volta ao normal

**Nível 3 — Remover tabela (1 min):**
```sql
ALTER TABLE execution_log DISABLE TRIGGER tr_execution_log_immutable;
DROP TABLE IF EXISTS execution_log;
DROP FUNCTION IF EXISTS prevent_execution_log_modification();
DROP FUNCTION IF EXISTS fn_execution_log_resumo(TIMESTAMPTZ, TIMESTAMPTZ);
DROP FUNCTION IF EXISTS fn_execution_log_user_timeline(TEXT, TIMESTAMPTZ, TIMESTAMPTZ);
```

---

# RESUMO DO TIME BLOCKING

| Bloco | Tempo | O que |
|-------|-------|-------|
| 1 | 0:00 - 0:15 | Criar tabela + testar Supabase |
| 2 | 0:15 - 0:35 | Criar workflow de log + testar N8N |
| 3.1 | 0:35 - 0:50 | Nós no Main (3 nós) |
| 3.2 | 0:50 - 1:20 | Nós no Premium (3 nós) |
| 3.3 | 1:20 - 1:50 | Nós no Standard (3+ nós) |
| 3.4 | 1:50 - 2:00 | Nós no Financeiro (3 nós) |
| 3.5 | 2:00 - 2:10 | Nós no Calendar (2 nós) |
| 4 | 2:10 - 2:30 | Validação end-to-end |
| **Total** | **2h30** | |

**Ordem de prioridade se faltar tempo:**
1. Bloco 1 + 2 (OBRIGATORIO — infraestrutura)
2. Bloco 3.3 Standard (CRITICO — hoje perde 100% dos dados)
3. Bloco 3.2 Premium (ALTO — captura classificação e tools)
4. Bloco 3.4 Financeiro (ALTO — captura deletes irreversíveis)
5. Bloco 3.1 Main (MEDIO — captura transcrições)
6. Bloco 3.5 Calendar (MEDIO — captura deletes de eventos)
