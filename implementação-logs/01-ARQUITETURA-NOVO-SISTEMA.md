# Arquitetura do Novo Sistema de Logs

**Data:** 2026-03-18
**Objetivo:** Capturar 100% das interações com contexto completo para auditoria

---

## Princípio: Log Centralizado

Em vez de adicionar múltiplos nós de log espalhados pelos workflows, vamos usar um **webhook centralizado de log**. Cada workflow envia os dados para um único ponto que persiste no Supabase.

### Por quê?
1. **Manutenção:** Um único ponto de log, não dezenas de nós espalhados
2. **Consistência:** Todos os logs seguem o mesmo schema
3. **Resiliência:** Se o log falhar, não afeta o fluxo principal do usuário
4. **Retrocompatibilidade:** Não modifica a lógica existente dos workflows, apenas adiciona nós no final

---

## Arquitetura

```
┌─────────────────────┐     ┌──────────────────────┐     ┌───────────────┐
│  Main Workflow      │     │  Premium Workflow     │     │ Standard WF   │
│  (onboarding +      │     │  (IA + ações)         │     │ (IA + ações)  │
│   roteamento)       │     │                       │     │               │
└────────┬────────────┘     └──────────┬────────────┘     └──────┬────────┘
         │                             │                          │
         │ POST                        │ POST                     │ POST
         │                             │                          │
         ▼                             ▼                          ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    WEBHOOK: Log Centralizado                            │
│                    /webhook/execution-log                               │
│                                                                         │
│  1. Recebe payload padronizado                                          │
│  2. Valida campos obrigatórios                                          │
│  3. INSERT na tabela execution_log                                      │
│  4. Retorna { success: true }                                           │
└──────────────────────────────────────────────────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────────────────────────────────────┐
│                    SUPABASE: execution_log                              │
│                                                                         │
│  Tabela única com TODOS os dados necessários para auditoria             │
│  RLS: service_role only (bloqueada para anon/authenticated)             │
└──────────────────────────────────────────────────────────────────────────┘
```

---

## Opção Escolhida: Webhook Interno N8N

Em vez de criar uma Edge Function no Supabase, usamos um **workflow N8N dedicado** que recebe o log via webhook e escreve no Supabase.

### Vantagens:
- Não precisa deploy de Edge Function
- Usa as credenciais Supabase já configuradas no N8N
- Pode ser monitorado no próprio N8N
- Não adiciona latência ao fluxo principal (chamada fire-and-forget)

### Workflow: "Execution Log - Total Assistente"

```
[Webhook Trigger]  →  [Validar Campos]  →  [Supabase: Create a row]  →  [Respond OK]
   /webhook/              Code node           INSERT execution_log
   execution-log
```

**Total: 4 nós.** Workflow simples e focado.

---

## Pontos de Inserção nos Workflows Existentes

### Main - Total Assistente

**Ponto 1: Após transcrição de áudio**
```
[Transcribe a recording] → [Redis SET transcricao] → [NOVO: HTTP POST /execution-log]
```
Dados enviados:
- user_phone, user_id, user_name
- message_type: "audio"
- transcription_text: texto transcrito
- source_workflow: "main"
- event_type: "transcription"

**Ponto 2: Após resumo de áudio**
```
[Message a model (resumo)] → [WhatsApp Send] → [NOVO: HTTP POST /execution-log]
```
Dados enviados:
- user_phone, transcription_text, summary_text
- event_type: "audio_summary"

**Ponto 3: Após roteamento para Premium/Standard**
```
[HTTP POST Premium User] → [NOVO: HTTP POST /execution-log]
```
Dados enviados:
- user_phone, message_type, raw_message
- event_type: "message_routed"
- routed_to: "premium" | "standard"

### Premium - Fix Conflito v2

**Ponto 4: Após "Escolher Branch"**
```
[Escolher Branch] → [Switch - Branches1] → [NOVO: HTTP POST /execution-log (paralelo)]
```
Dados enviados:
- user_phone, user_id, user_message
- branch_classification: resultado do classificador
- event_type: "classification"

**Ponto 5: Após AI Agent + Code in JavaScript (parse)**
```
[Code in JavaScript] → [Switch2] → [NOVO: HTTP POST /execution-log (paralelo)]
```
Dados enviados:
- user_phone, user_id
- ai_full_response: JSON completo (acao + mensagem + tool)
- ai_action: campo `acao`
- ai_tools_called: campo `tool` (array de tools chamadas)
- ai_message: campo `mensagem`
- event_type: "ai_response"

**Ponto 6: Após execução de ação (create tool, calendar tool, etc.)**
```
[HTTP - Create Tool] → resposta → [NOVO: HTTP POST /execution-log]
```
Dados enviados:
- action_type: "registrar_financeiro" | "criar_evento" | etc.
- action_input: dados enviados ao webhook
- action_output: resposta do webhook
- action_success: true/false
- event_type: "action_executed"

**Ponto 7: Consolidação final (substitui Create a row1 atual)**
```
[Após todas as ações] → [NOVO: HTTP POST /execution-log]
```
Dados enviados:
- TODOS os campos consolidados da interação
- event_type: "interaction_complete"

### Standard - User Standard - Total

**Mesmos pontos 4, 5, 6 e 7 do Premium.** A principal diferença é que o Standard hoje não loga NADA, então todos esses pontos são novos.

---

## Fluxo com Novo Sistema (Diagrama)

```
MENSAGEM WHATSAPP
    │
    ▼
┌─ MAIN ────────────────────────────────┐
│ 1. Normaliza payload                  │
│ 2. Identifica tipo (texto/audio/img)  │
│ 3. Se audio:                          │
│    ├─ Transcreve                      │
│    ├─ LOG 📝 transcription            │
│    └─ Se resumo:                      │
│        └─ LOG 📝 audio_summary        │
│ 4. Roteia para Premium/Standard       │
│    └─ LOG 📝 message_routed           │
└───────────────────────────────────────┘
    │
    ▼
┌─ PREMIUM/STANDARD ────────────────────┐
│ 1. Debounce                           │
│ 2. Classificar intent                 │
│    └─ LOG 📝 classification           │
│ 3. AI Agent processa                  │
│    └─ LOG 📝 ai_response              │
│ 4. Executa ação                       │
│    └─ LOG 📝 action_executed          │
│ 5. Formata e envia WhatsApp           │
│ 6. Consolidação                       │
│    └─ LOG 📝 interaction_complete     │
└───────────────────────────────────────┘
    │
    ▼
┌─ WEBHOOK EXECUTION-LOG ──────────────┐
│ Recebe POST → Valida → INSERT Supabase│
└───────────────────────────────────────┘
```

---

## Considerações de Performance

### Latência
- Os nós de log são chamados via HTTP POST com **timeout curto (5s)**
- Se o log falhar, o fluxo principal NÃO é afetado (fire-and-forget)
- O nó de log deve estar em um branch **paralelo**, não sequencial

### Volume
- Estimativa: ~7 eventos por interação completa
- Se 100 mensagens/dia → ~700 inserts/dia → trivial para Supabase

### Retry
- Sem retry automático — se perdeu, perdeu
- Melhor perder um log eventual do que impactar performance
- O cruzamento de fontes no squad auditor compensa perdas pontuais

---

## Próximos Passos

1. **[02-MIGRATION-SQL.md]** — SQL para criar tabela `execution_log`
2. **[03-WORKFLOW-LOG-CENTRALIZADO.md]** — JSON do workflow N8N receptor
3. **[04-NODES-MAIN.md]** — Nós a adicionar no Main
4. **[05-NODES-PREMIUM.md]** — Nós a adicionar no Premium
5. **[06-NODES-STANDARD.md]** — Nós a adicionar no Standard
6. **[07-PASSO-A-PASSO.md]** — Guia de implementação
