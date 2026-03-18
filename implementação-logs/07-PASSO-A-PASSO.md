# Guia de Implementação — Passo a Passo

**Data:** 2026-03-18
**Estimativa:** ~2-3 horas de implementação

---

## Pré-requisitos

- Acesso admin ao Supabase (projeto ldbdtakddxznfridsarn)
- Acesso admin ao N8N (n8n.totalassistente.com.br)
- Credencial Supabase já configurada no N8N

---

## Fase 1: Criar a Tabela (Supabase)

### Passo 1.1: Executar migration SQL

1. Abrir o Supabase Dashboard → SQL Editor
2. Colar o conteúdo de `02-MIGRATION-SQL.sql`
3. Executar
4. Verificar: ir em Table Editor → `execution_log` deve aparecer
5. Verificar RLS: em Authentication → Policies → execution_log deve ter 2 policies

### Passo 1.2: Testar acesso

```sql
-- Deve retornar 0 rows (tabela vazia)
SELECT * FROM execution_log LIMIT 1;

-- Deve funcionar com service_role
INSERT INTO execution_log (user_phone, source_workflow, event_type)
VALUES ('5543999999999', 'test', 'classification');

-- Verificar
SELECT * FROM execution_log;

-- Limpar teste
DELETE FROM execution_log WHERE source_workflow = 'test';
```

---

## Fase 2: Criar Workflow de Log (N8N)

### Passo 2.1: Importar workflow

1. N8N → Workflows → Importar from File
2. Importar `03-WORKFLOW-LOG-CENTRALIZADO.json`
3. **IMPORTANTE:** Editar o nó `Salvar execution_log`:
   - Clicar no nó → Credential → Selecionar a credencial Supabase existente
   - Verificar que `tableId` = `execution_log`

### Passo 2.2: Configurar error handling

1. No nó `Validar e Normalizar`:
   - Clicar em Settings → On Error → selecionar `Continue Using Error Output`
   - Conectar o Error Output ao nó `Responder Erro`

2. No nó `Salvar execution_log`:
   - Clicar em Settings → On Error → selecionar `Continue Using Error Output`
   - Conectar o Error Output ao nó `Responder Erro`

### Passo 2.3: Testar o workflow

1. Ativar o workflow
2. Abrir terminal e testar:

```bash
curl -X POST https://n8n.totalassistente.com.br/webhook/execution-log \
  -H "Content-Type: application/json" \
  -d '{
    "user_phone": "5543999999999",
    "user_name": "Teste Manual",
    "user_message": "Oi, tudo bem?",
    "ai_message": "Olá! Como posso ajudar?",
    "source_workflow": "test",
    "event_type": "interaction_complete",
    "branch": "padrao"
  }'
```

3. Verificar no Supabase:
```sql
SELECT * FROM execution_log WHERE source_workflow = 'test';
```

4. Se funcionou, limpar:
```sql
DELETE FROM execution_log WHERE source_workflow = 'test';
```

### Passo 2.4: Anotar URL do webhook

A URL do webhook será algo como:
```
https://n8n.totalassistente.com.br/webhook/execution-log
```

ou (se usar webhook de produção):
```
https://totalassistente.com.br/webhook/execution-log
```

**Usar esta URL em todos os nós de log dos workflows.**

---

## Fase 3: Adicionar Logs no Main

### Passo 3.1: Abrir workflow "Main - Total Assistente"

1. N8N → Workflows → Main - Total Assistente
2. **Fazer backup antes:** Exportar workflow atual como JSON

### Passo 3.2: Adicionar "LOG: Transcrição"

1. Localizar o nó `Redis` (que faz SET da transcrição)
2. Adicionar novo nó HTTP Request ao lado
3. Configurar conforme `04-NODES-MAIN.md` → Nó 1
4. Conectar: `Redis` → `LOG: Transcrição` (criar uma segunda conexão saindo do Redis, mantendo a conexão original)
5. Marcar `continueOnFail: true` nas Settings do nó

### Passo 3.3: Adicionar "LOG: Resumo Áudio"

1. Localizar o nó `Message a model` (resumo)
2. Adicionar novo nó HTTP Request ao lado
3. Configurar conforme `04-NODES-MAIN.md` → Nó 2
4. Conectar em paralelo após `Message a model`
5. Marcar `continueOnFail: true`

### Passo 3.4: Adicionar "LOG: Roteamento"

1. Localizar o nó `Premium User` (HTTP Request que roteia)
2. Adicionar novo nó HTTP Request ao lado
3. Configurar conforme `04-NODES-MAIN.md` → Nó 3
4. Conectar em paralelo após `Premium User`
5. Marcar `continueOnFail: true`

### Passo 3.5: Salvar e testar Main

1. Salvar o workflow
2. Enviar uma mensagem de texto pelo WhatsApp de teste
3. Verificar no Supabase:
```sql
SELECT * FROM execution_log
WHERE source_workflow = 'main'
ORDER BY created_at DESC
LIMIT 5;
```

---

## Fase 4: Adicionar Logs no Premium

### Passo 4.1: Abrir workflow "Fix Conflito v2"

1. N8N → Workflows → Fix Conflito v2
2. **Fazer backup antes**

### Passo 4.2: Adicionar nós conforme `05-NODES-PREMIUM.md`

Seguir a ordem:
1. LOG: Classificação (após Escolher Branch)
2. LOG: Resposta IA (após Code in JavaScript)
3. LOG: Ação Financeiro (após cada HTTP Create Tool)
4. LOG: Ação Agenda (após cada HTTP Create Calendar Tool)
5. LOG: Extração Doc (após PDF Extractor)
6. LOG: Consolidação (após Create a row1)

**Para cada nó:**
- Criar HTTP Request
- Copiar configuração do documento
- Conectar em PARALELO (não sequencial)
- Marcar `continueOnFail: true`
- Posicionar abaixo do nó original para manter o canvas organizado

### Passo 4.3: Salvar e testar Premium

1. Salvar
2. Enviar mensagem de teste (ex: "Gastei 50 no almoço")
3. Verificar:
```sql
SELECT event_type, branch, ai_action, ai_message, created_at
FROM execution_log
WHERE source_workflow = 'premium'
ORDER BY created_at DESC
LIMIT 10;
```

---

## Fase 5: Adicionar Logs no Standard

### Passo 5.1: Abrir workflow "User Standard - Total"

1. N8N → Workflows → User Standard - Total
2. **Fazer backup antes**

### Passo 5.2: Adicionar nós conforme `06-NODES-STANDARD.md`

Mesma sequência do Premium. **Este é o mais impactante** porque hoje o Standard não loga NADA.

### Passo 5.3: Salvar e testar Standard

```sql
SELECT event_type, branch, ai_action, ai_message, created_at
FROM execution_log
WHERE source_workflow = 'standard'
ORDER BY created_at DESC
LIMIT 10;
```

---

## Fase 6: Validação Final

### Passo 6.1: Checklist de validação

Para cada workflow (Main, Premium, Standard), verificar:

- [ ] Nós de log adicionados conforme documentação
- [ ] Todos os nós têm `continueOnFail: true`
- [ ] Nós de log estão em PARALELO (não bloqueiam fluxo principal)
- [ ] Workflow de log centralizado está ATIVO
- [ ] Dados chegam na tabela `execution_log`
- [ ] Campos `user_phone`, `source_workflow` e `event_type` sempre preenchidos

### Passo 6.2: Teste end-to-end

1. Enviar áudio pelo WhatsApp → Verificar `event_type = 'transcription'`
2. Solicitar resumo → Verificar `event_type = 'audio_summary'`
3. Registrar gasto → Verificar `event_type = 'classification'` + `'ai_response'` + `'action_executed'` + `'interaction_complete'`
4. Criar evento → Mesma verificação
5. Mensagem genérica ("oi") → Verificar `branch = 'padrao'`

### Passo 6.3: Query de validação completa

```sql
-- Contagem por event_type (deve ter todos os tipos)
SELECT event_type, COUNT(*)
FROM execution_log
GROUP BY event_type
ORDER BY count DESC;

-- Contagem por source_workflow
SELECT source_workflow, COUNT(*)
FROM execution_log
GROUP BY source_workflow;

-- Verificar se Standard está logando
SELECT COUNT(*)
FROM execution_log
WHERE source_workflow = 'standard';

-- Verificar se transcrições estão sendo salvas
SELECT user_phone, transcription_text, summary_text, created_at
FROM execution_log
WHERE event_type IN ('transcription', 'audio_summary')
ORDER BY created_at DESC
LIMIT 5;
```

---

## Ordem de Implementação Recomendada

| # | Fase | Risco | Tempo |
|---|------|-------|-------|
| 1 | Criar tabela Supabase | Nenhum | 5 min |
| 2 | Criar workflow de log | Baixo | 15 min |
| 3 | Testar workflow isolado | Nenhum | 5 min |
| 4 | Logs no Main | Baixo | 20 min |
| 5 | Logs no Premium | Baixo | 30 min |
| 6 | Logs no Standard | Baixo | 30 min |
| 7 | Validação end-to-end | Nenhum | 15 min |

**Risco geral: BAIXO** — todos os nós usam `continueOnFail: true` e são paralelos, então mesmo se falharem, o fluxo principal não é afetado.

---

## Rollback

Se algo der errado:

1. **Workflow de log:** Desativar o workflow "Execution Log - Total Assistente"
2. **Nós adicionados:** Deletar os nós "LOG: *" dos workflows (não afeta os nós originais)
3. **Tabela:** `DROP TABLE IF EXISTS execution_log;` (apenas se necessário)

Nenhuma modificação é feita nos nós existentes dos workflows. Apenas nós NOVOS são adicionados em paralelo.
