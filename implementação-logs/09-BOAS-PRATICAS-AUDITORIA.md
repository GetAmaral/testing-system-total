# Boas Práticas de Auditoria Aplicadas

**Data:** 2026-03-18
**Referências:** SOC 2 Type II, ISO 27001, OWASP Logging Cheat Sheet, NIST SP 800-92

---

## 1. Princípios Fundamentais de Audit Trail

### 1.1 Completude (Completeness)
> "Se não está no log, não aconteceu."

**Aplicação no execution_log:**
- TODA ação que modifica dados DEVE ser logada
- TODA mensagem enviada ao usuário DEVE ser logada
- TODA decisão do AI Agent (classificação, tool selection) DEVE ser logada
- Ações de infraestrutura (OAuth refresh, etc.) podem ser excluídas

### 1.2 Imutabilidade (Immutability)
> "Logs não podem ser alterados ou deletados."

**Aplicação:**
```sql
-- RLS bloqueia UPDATE e DELETE para todos
-- Apenas INSERT é permitido via service_role
CREATE POLICY "Append-only execution_log"
    ON public.execution_log
    FOR INSERT
    TO service_role
    WITH CHECK (true);

-- Nenhuma policy para UPDATE ou DELETE
-- = impossível alterar logs via API
```

**Recomendação adicional:** Criar trigger que bloqueia UPDATE/DELETE mesmo via service_role:
```sql
CREATE OR REPLACE FUNCTION prevent_log_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'execution_log is append-only. Modification not allowed.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_execution_log_immutable
  BEFORE UPDATE OR DELETE ON execution_log
  FOR EACH ROW
  EXECUTE FUNCTION prevent_log_modification();
```

### 1.3 Não-repúdio (Non-repudiation)
> "Deve ser possível provar quem fez o quê, quando."

**Campos que garantem não-repúdio:**
- `user_phone` — identifica o usuário
- `user_id` — UUID único
- `created_at` — timestamp do servidor (não do cliente)
- `source_workflow` — qual sistema executou
- `execution_id` — ID da execução no N8N (rastreável)

### 1.4 Integridade (Integrity)
> "Logs devem ser confiáveis e precisos."

**Aplicação:**
- `created_at` usa `DEFAULT NOW()` do PostgreSQL (timestamp do servidor, não manipulável)
- `message_timestamp` é o timestamp do WhatsApp (pode divergir do `created_at`)
- Campos JSONB armazenam dados brutos (sem sanitização que perca informação)
- `continueOnFail: true` nos nós de log — se falhar, não corrompe o dado original

---

## 2. Campos Obrigatórios por Padrão de Auditoria

### Baseado em OWASP Logging Cheat Sheet:

| Campo | OWASP | execution_log | Status |
|-------|-------|--------------|--------|
| **When** (timestamp) | Obrigatório | `created_at`, `message_timestamp` | OK |
| **Who** (identidade) | Obrigatório | `user_phone`, `user_id`, `user_name` | OK |
| **Where** (origem) | Obrigatório | `source_workflow`, `execution_id` | OK |
| **What** (ação) | Obrigatório | `event_type`, `action_type`, `branch` | OK |
| **Result** (sucesso/falha) | Obrigatório | `action_success`, `error_message` | OK |
| **Severity** (criticidade) | Recomendado | Não existe | ADICIONAR |
| **Input** (dados de entrada) | Recomendado | `action_input`, `user_message` | OK |
| **Output** (dados de saída) | Recomendado | `action_output`, `ai_message` | OK |

### Campo recomendado a adicionar: `severity`

```sql
ALTER TABLE execution_log
ADD COLUMN severity TEXT DEFAULT 'info'
CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical'));
```

**Mapeamento automático:**
| Situação | Severity |
|----------|----------|
| Mensagem processada com sucesso | info |
| Transcrição de áudio | info |
| Classificação de intent | info |
| Ação financeira executada | info |
| DELETE executado | warning |
| Falha na execução | error |
| Dado financeiro incorreto detectado | critical |
| Mensagem sem resposta | error |

---

## 3. Separação por Usuário

### 3.1 Indexação adequada

Os índices criados em `02-MIGRATION-SQL.sql` já garantem queries rápidas por usuário:

```sql
-- Query por telefone (principal)
CREATE INDEX idx_execution_log_user_phone ON execution_log (user_phone);

-- Query por user_id (secundário)
CREATE INDEX idx_execution_log_user_id ON execution_log (user_id);

-- Query composta: usuário + período
CREATE INDEX idx_execution_log_user_phone_created
    ON execution_log (user_phone, created_at DESC);
```

### 3.2 Normalização de telefone

**Problema:** O mesmo usuário pode aparecer com formatos diferentes:
- `554391936205`
- `+554391936205`
- `55 43 91936205`

**Solução:** O nó "Validar e Normalizar" no workflow de log já trata isso:
```javascript
const normalizePhone = (phone) => {
  if (!phone) return null;
  return phone.toString().replace(/[^0-9]/g, '');
};
```

### 3.3 Vinculação phone → user_id

**Problema:** Alguns workflows têm apenas `user_phone`, outros apenas `user_id`.

**Solução para queries de auditoria:**
```sql
-- Buscar por telefone OU por ID
SELECT * FROM execution_log
WHERE user_phone = '{phone}'
   OR user_id = (SELECT id FROM profiles WHERE phone = '{phone}')
ORDER BY created_at ASC;
```

---

## 4. Retenção de Dados (Data Retention)

### Política recomendada:

| Período | Ação |
|---------|------|
| 0-90 dias | Dados completos, acesso total |
| 90-365 dias | Dados completos, acesso via query |
| 1-3 anos | Dados arquivados (comprimidos) |
| 3+ anos | Avaliar exclusão conforme LGPD |

### Implementação futura (quando necessário):

```sql
-- Particionar por mês para performance
CREATE TABLE execution_log_2026_03 PARTITION OF execution_log
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

-- Ou mover dados antigos para tabela de arquivo
INSERT INTO execution_log_archive
SELECT * FROM execution_log
WHERE created_at < NOW() - INTERVAL '90 days';
```

**Por agora:** Sem necessidade de particionamento. Volume estimado (~700 inserts/dia) é trivial para PostgreSQL.

---

## 5. Proteção contra Dados Sensíveis no Log

### O que NÃO logar:
- Senhas ou hashes de senha
- Tokens OAuth (access_token, refresh_token)
- Chaves de API
- Dados de cartão de crédito
- CPF completo

### O que LOGAR com cuidado:
- `user_message`: pode conter dados pessoais → OK logar (necessário para auditoria)
- `ai_message`: pode conter dados do usuário → OK logar
- `action_input`: pode ter valores financeiros → OK logar (dados do próprio usuário)
- `ai_full_response`: pode ter tool outputs → OK logar

### Campos já protegidos:
- Tokens OAuth: workflows de infraestrutura (refresh_access) são EXCLUÍDOS do log
- Chaves de API: nunca presentes nos payloads dos nós logados

---

## 6. Monitoramento e Alertas (Futuro)

### Queries de monitoramento recomendadas:

```sql
-- Erros nas últimas 24h
SELECT COUNT(*), source_workflow, event_type
FROM execution_log
WHERE error_message IS NOT NULL
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY source_workflow, event_type;

-- Ações destrutivas (DELETE) nas últimas 24h
SELECT user_phone, user_name, action_type, action_input, created_at
FROM execution_log
WHERE action_type LIKE 'excluir%'
  AND created_at > NOW() - INTERVAL '24 hours'
ORDER BY created_at DESC;

-- Usuários com mais erros
SELECT user_phone, COUNT(*) as error_count
FROM execution_log
WHERE error_message IS NOT NULL
  AND created_at > NOW() - INTERVAL '7 days'
GROUP BY user_phone
ORDER BY error_count DESC
LIMIT 10;

-- Volume por hora (detectar anomalias)
SELECT date_trunc('hour', created_at) as hora,
       COUNT(*) as volume
FROM execution_log
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY hora
ORDER BY hora;
```

---

## 7. Checklist de Compliance

### Antes de ir para produção:

- [ ] Tabela `execution_log` criada com RLS ativa
- [ ] Trigger de imutabilidade ativo (prevent UPDATE/DELETE)
- [ ] Workflow de log centralizado ativo e testado
- [ ] Todos os nós de log com `continueOnFail: true`
- [ ] Normalização de telefone funcionando
- [ ] Timestamp do servidor (`created_at DEFAULT NOW()`)
- [ ] Sem dados sensíveis nos logs (tokens, senhas)
- [ ] Índices criados para queries por user_phone e created_at
- [ ] Teste end-to-end: mensagem → log → query → dados corretos
- [ ] Backup configurado para a tabela (herda do backup geral do Supabase)

### Após 1 semana em produção:

- [ ] Verificar volume de logs (esperado: ~700/dia)
- [ ] Verificar cobertura: todos os event_types aparecendo
- [ ] Verificar que Standard está logando (GAP-01 resolvido)
- [ ] Verificar transcrições de áudio persistindo (GAP-02 resolvido)
- [ ] Executar queries de monitoramento
- [ ] Ajustar nós que não estão capturando dados esperados
