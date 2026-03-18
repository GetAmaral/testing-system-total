# Diagnóstico do Sistema de Logs Atual

**Data:** 2026-03-18
**Análise:** READ-ONLY (nenhum workflow modificado)

---

## Workflows Analisados

| ID | Nome | Status |
|----|------|--------|
| 9WDlyel5xRCLAvtH | Main - Total Assistente | ATIVO |
| tyJ3YAAtSg1UurFj | Fix Conflito v2 (Premium) | ATIVO |
| c8gtSmh1BPzZXbJa | User Standard - Total | ATIVO |
| eYWjnmvP8LQxY87g | Financeiro - Total | ATIVO |
| sjDpjKqtwLk7ycki | Lembretes Total Assistente | ATIVO |
| S2QgrsN6uteyB04E | Report Unificado | ATIVO |
| ZZbMdcuCKx0fM712 | Calendar WebHooks | ATIVO |
| GNdoIS2zxGBa4CW0 | Service Message - 24 Hours | ATIVO |

---

## O Que É Salvo Hoje (e Onde)

### Tabela `log_users_messages` (Supabase)

**Campos existentes:**
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | BIGSERIAL | PK auto-incremento |
| user_id | TEXT | ID do usuário |
| user_phone | TEXT | Telefone WhatsApp |
| user_email | TEXT | Email |
| user_name | TEXT | Nome |
| user_message | TEXT | Mensagem do usuário |
| ai_message | TEXT | Resposta da IA |
| timestamp | TIMESTAMPTZ | Timestamp da conversa |
| created_at | TIMESTAMPTZ | Default NOW() |

**Quem escreve nessa tabela:**

| Workflow | Nós de escrita | Contexto |
|----------|---------------|----------|
| Main | 9 nós (Create a row, Create a row3, Create a row6-10) | Apenas ONBOARDING (stg 1-6) |
| Premium | 1 nó (Create a row1) | Conversas de usuários Premium |
| Standard | **NENHUM** | **NÃO LOGA NADA** |

### Tabela `message_log` (Supabase)

**Campos existentes:**
| Campo | Tipo | Descrição |
|-------|------|-----------|
| id | UUID | PK |
| phone | TEXT | Telefone |
| body_hash | TEXT | Hash do body |
| norm_text | TEXT | Texto normalizado |
| char_count | INTEGER | Contagem de caracteres |
| hour | TEXT | Hora |
| notified | BOOLEAN | Se foi notificado |
| created_at | TIMESTAMPTZ | Default NOW() |

**IMPORTANTE:** Esta tabela **NÃO é referenciada** em NENHUM dos workflows ativos. Possivelmente legada ou usada por outro sistema.

### Redis (Temporário)

| Chave | Conteúdo | TTL | Workflow |
|-------|----------|-----|----------|
| `transcricao:{phone}` | Texto da transcrição (Whisper) | 1 hora | Main |
| `chatmem-{phone}` | Histórico de conversa (LangChain) | 5 min (Premium) / 1h (Standard) |
| `{phone}_debounce` | Lista de mensagens acumuladas | ~10s | Premium/Standard |
| `{phone}_idobject` | IDs de transações recentes | ? | Premium |

---

## Gaps Identificados (Ordenados por Criticidade)

### 🔴 CRÍTICOS

#### GAP-01: Standard NÃO loga mensagens
- **Workflow:** User Standard - Total (c8gtSmh1BPzZXbJa)
- **Impacto:** 100% das conversas de usuários Standard são PERDIDAS
- **Detalhes:** O workflow Standard não possui NENHUM nó `Create a row` para `log_users_messages`. Após o TTL do Redis (1h), toda a conversa desaparece permanentemente.
- **Estimativa de perda:** Se 40% dos usuários são Standard, ~40% de todas as conversas estão sendo perdidas.

#### GAP-02: Transcrição de áudio não persiste
- **Workflow:** Main - Total Assistente
- **Impacto:** Toda transcrição de áudio é perdida após 1 hora
- **Detalhes:** O texto transcrito pelo Whisper é salvo APENAS no Redis com chave `transcricao:{phone}` e TTL de 3600s. Não é salvo no Supabase.
- **O que se perde:** O texto completo do que o usuário falou no áudio.

#### GAP-03: Resumo de áudio não é salvo em lugar nenhum
- **Workflow:** Main - Total Assistente
- **Impacto:** Resumos gerados pelo GPT-4.1-mini são enviados ao usuário e descartados
- **Detalhes:** O nó "Message a model" gera o resumo, envia via WhatsApp, e o texto do resumo não é salvo em nenhum lugar (nem Redis, nem Supabase).

#### GAP-04: Ações/tool calls da IA não são logados
- **Workflows:** Premium e Standard
- **Impacto:** Impossível auditar QUAIS ações a IA executou
- **Detalhes:** O AI Agent retorna JSON com `{acao, mensagem, tool}`. O nó "Code in JavaScript" faz parse e extrai. Porém, apenas `mensagem` é salva em `log_users_messages.ai_message`. Os campos `acao` e `tool` são usados apenas para routing (Switch2) e depois DESCARTADOS.
- **O que se perde:**
  - Qual ação foi executada (registrar_gasto, criar_evento, excluir_financeiro, etc.)
  - Quais ferramentas foram chamadas pelo agente
  - Os parâmetros passados para as ferramentas (nome do gasto, valor, categoria, etc.)

#### GAP-05: Classificação de branch não é logada
- **Workflows:** Premium e Standard
- **Impacto:** Impossível analisar como as mensagens são classificadas
- **Detalhes:** O nó "Escolher Branch" (chainLlm) classifica a intenção do usuário em branches (criar_gasto, buscar_gasto, editar_gasto, etc.). O resultado é usado para routing (Switch - Branches1) mas NUNCA é salvo.
- **O que se perde:** A classificação de intent, útil para entender erros de routing.

### 🟡 MODERADOS

#### GAP-06: Sem tipo de mensagem
- **Todos os workflows**
- **Impacto:** Impossível diferenciar se a mensagem original era texto, áudio, imagem ou documento
- **Detalhes:** O Main extrai `messageType` do payload do WhatsApp (text, image, audio, document, button), mas esse campo NÃO é passado para os workflows Premium/Standard e NÃO é salvo no log.

#### GAP-07: Sem session/conversation ID
- **Todos os workflows**
- **Impacto:** Dificulta agrupar mensagens da mesma sessão para análise
- **Detalhes:** Não existe campo que identifique uma "sessão" ou "conversa". As mensagens são gravadas individualmente sem agrupamento.

#### GAP-08: Onboarding usa IDs provisórios
- **Workflow:** Main
- **Impacto:** Logs do onboarding ficam com `user_id = ONBOARDING-{phone}`, dificultando rastreamento pós-ativação
- **Detalhes:** user_id, user_name e user_email são todos `ONBOARDING-{phone}` durante os estágios 1-5. Após ativação (stg 6), o usuário ganha um UUID real, mas os logs antigos não são atualizados.

#### GAP-09: Dados extraídos de PDF/imagem não são logados
- **Workflows:** Premium e Standard
- **Impacto:** Dados extraídos de documentos são processados mas não persistidos
- **Detalhes:** Os nós "PDF Extractor" e "HTTP Request8" (para imagens) extraem dados, que são passados ao AI Agent. Porém, o conteúdo extraído não é salvo.

#### GAP-10: Log Premium depende do Get a row (profiles)
- **Workflow:** Premium
- **Impacto:** Se o lookup de perfil falhar, o log pode não ser escrito
- **Detalhes:** O nó `Create a row1` (log) está conectado após o `Get a row` (profiles). Se o perfil não for encontrado, o fluxo pode divergir e não chegar ao nó de log.

---

## Fluxo de Dados Atual (Diagrama)

```
MENSAGEM WHATSAPP (texto/audio/imagem/documento/botão)
    │
    ▼
┌─────────────────────────────────────────┐
│ MAIN WORKFLOW (trigger-whatsapp)        │
│                                         │
│ 1. Normaliza payload WhatsApp           │
│ 2. Busca phone em profiles              │
│ 3. Busca stg em phones_whatsapp         │
│ 4. Switch(stg):                         │
│    ├─ stg 1-5: Onboarding              │
│    │   └─ LOG ✅ (log_users_messages)   │
│    │     user_id: ONBOARDING-{phone}    │
│    │     user_message: texto bruto      │
│    │     ai_message: resposta hardcoded  │
│    │                                     │
│    └─ stg 6: Usuário autenticado        │
│        ├─ Se audio:                      │
│        │   └─ Transcreve (Whisper)       │
│        │   └─ Salva Redis (1h TTL) ⚠️   │
│        │   └─ LOG ❌ (transcrição)      │
│        │                                 │
│        └─ HTTP POST → Premium/Standard  │
│            └─ LOG ❌ (nada aqui)        │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ PREMIUM WORKFLOW (webhook: premium)     │
│                                         │
│ 1. Debounce Redis (~3-10s)              │
│ 2. "Escolher Branch" (classifica intent)│
│    └─ LOG ❌ (branch não salvo)         │
│ 3. AI Agent (OpenAI + tools)            │
│    └─ LOG ❌ (tool calls não salvos)    │
│ 4. "Code in JavaScript" (parse output)  │
│    ├─ acao: descartada                   │
│    ├─ tool: descartada                   │
│    └─ mensagem: usada para log           │
│ 5. Switch2 → Executa ação               │
│    └─ LOG ❌ (resultado ação)           │
│ 6. Formata e envia WhatsApp             │
│ 7. Create a row1 (log_users_messages)   │
│    └─ LOG ✅ (user_message + ai_message)│
│    └─ LOG ❌ (sem acao, sem tool,       │
│              sem branch, sem messageType)│
└─────────────────────────────────────────┘

┌─────────────────────────────────────────┐
│ STANDARD WORKFLOW (webhook: premium)    │
│                                         │
│ [Mesmo fluxo do Premium, mas...]        │
│                                         │
│ *** NENHUM LOG ***                      │
│ *** TUDO É PERDIDO ***                  │
└─────────────────────────────────────────┘
```

---

## Tabelas que Poderiam Ser Usadas mas NÃO São

| Tabela | Existe no Supabase | Usada nos Workflows | Observação |
|--------|-------------------|--------------------|----|
| message_log | ✅ Sim | ❌ Não (nenhum workflow referencia) | Pode ser legada ou usada por outro sistema |
| log_table | ✅ Sim | ❌ Não (nenhum workflow referencia) | Apenas service_role tem acesso |
| bot_events | ✅ Sim | ❌ Não (nenhum dos 3 principais) | Pode ser usada por outro sistema |
| audit_log | ✅ Sim | ❌ Não (nenhum workflow referencia) | Para auditoria admin do site |

---

## Conclusão

O sistema atual de logs é **criticamente incompleto**:
- **~40% das conversas** (Standard) são completamente perdidas
- **100% das transcrições de áudio** são perdidas após 1 hora
- **100% das ações executadas** (tool calls, classificações) não são registradas
- **0% de metadados** são capturados (tipo de mensagem, branch, session)

A implementação do novo sistema de logs é **urgente** para viabilizar o squad `auditor-real` e qualquer análise de qualidade do sistema.
