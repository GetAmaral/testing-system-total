# Bateria de Testes #04 — Verificação REAL (como um usuário)
**Data:** 2026-03-15
**Metodologia:** Criar → Verificar → Editar → Verificar → Excluir → Verificar

---

## MÓDULO 12: GASTOS — Criar/Editar/Excluir com Verificação

| Passo | Ação | Verificação | Resultado |
|-------|------|-------------|-----------|
| 12.1 | Criar: "gastei 250 com macaco" | — | ✅ Criou R$250 Macaco |
| 12.2 | Verificar: "quanto gastei hoje?" | Macaco R$250 apareceu | ✅ CONFIRMADO no banco |
| 12.3 | Editar valor: "macaco era 300, não 250" | — | IA disse ✅ Valor atualizado R$300 |
| 12.4 | **Verificar edição:** "quanto gastei hoje?" | **Macaco R$300 apareceu** | ✅ **REALMENTE editou no banco** |
| 12.5 | Editar nome: "macaco era mecânico" | — | IA disse ✅ Mecânico R$300 |
| 12.6 | **Verificar rename:** "quanto gastei hoje?" | **Mecânico R$300 apareceu** | ✅ **REALMENTE renomeou E manteve R$300** |
| 12.7 | Excluir: "apaga gasto do mecânico" | — | IA disse 🗑️ Mecânico R$300 excluído |
| 12.8 | **Verificar exclusão:** "quanto gastei hoje?" | **Mecânico sumiu do extrato** | ✅ **REALMENTE excluiu** |

### Conclusão Gastos:
**Edição e exclusão de gastos funcionam corretamente.** O bug que achamos na Bateria 02 (edição revertendo valores) foi um falso positivo — a IA exibia o valor antigo na confirmação mas o banco estava correto.

### Latência:
| Operação | Latência |
|----------|----------|
| Criar gasto | 7.7s |
| Buscar gastos | 9-12s |
| Editar gasto | 14.4s |
| Excluir gasto | 9.7s |

---

## MÓDULO 13: EVENTOS — Criar/Editar/Excluir com Verificação

| Passo | Ação | Verificação | Resultado |
|-------|------|-------------|-----------|
| 13.1 | Criar: "consulta médico dia 20 às 10h" | — | ✅ Criou 20/03 10:00 |
| 13.2 | Verificar: "o que tenho dia 20?" | Consulta No Médico 10h apareceu | ✅ CONFIRMADO |
| 13.3 | Editar data/hora: "muda pro dia 21 às 14h" | — | IA disse ✅ 21/03 14:00 |
| 13.4 | **Verificar edição:** "o que tenho dia 21?" | **Consulta No Médico 14h apareceu** | ✅ **REALMENTE editou** |
| 13.5 | Editar nome: "renomeia para consulta dermatologista" | — | IA disse ✅ consulta dermatologista |
| 13.6 | **Verificar rename:** "o que tenho dia 21?" | **"Não encontrei eventos"** | ❌ **RENAME QUEBROU O EVENTO** |
| 13.7 | Excluir: "exclui consulta dermatologista" | — | "Não encontrei" | ❌ **EVENTO PERDIDO** |
| 13.8 | Verificar: "o que tenho dia 21?" | Consulta sumiu completamente | ❌ **EVENTO FOI DELETADO ao renomear** |

### Conclusão Eventos:

**RENOMEAR EVENTO DELETA O EVENTO DO CALENDÁRIO.**

O rename (13.5) retornou sucesso, mas na verificação (13.6) o evento sumiu completamente. A consulta (13.8) confirma que o evento não existe mais com nenhum nome.

### Hipótese:
O workflow `editar_eventos` provavelmente:
1. Busca o evento por nome ("Consulta no Médico")
2. Deleta o evento antigo
3. Cria um novo evento com o novo nome
4. Mas o passo 3 falha silenciosamente → evento é perdido

OU:
1. O rename muda o nome no Supabase mas não no Google Calendar
2. A consulta de agenda lê do Google Calendar (que ainda tem o nome antigo ou deletou)
3. Conflito entre fonte de dados

### Dados adicionais preocupantes:
Na agenda do dia 21, apareceram eventos com nomes ofensivos ("Aids", "Bucetinha") — provavelmente testes de outros usuários com o mesmo telefone.

---

## MAPA COMPLETO DE BUGS CONFIRMADOS vs FALSOS POSITIVOS

### CONFIRMADOS (verificação real):
| Bug | Status | Detalhes |
|-----|--------|----------|
| Rename de evento DELETE o evento | ❌ CONFIRMADO | Evento some do calendário após rename |
| Evento renomeado não é encontrável | ❌ CONFIRMADO | Busca e exclusão falham após rename |
| Latência de edição de eventos (~23s) | ⚠️ CONFIRMADO | Mas não 45-68s como antes (Redis pode ter voltado parcialmente) |

### FALSOS POSITIVOS (corrigidos):
| Bug original | Realidade |
|---|---|
| "Edição de gasto reverte mudanças" | ❌ FALSO — o banco estava correto, só a mensagem da IA exibia o valor antigo |
| "Exclusão de gasto errada" | ❌ FALSO — exclusão funciona corretamente |

---

## ANÁLISE DE GARGALOS DO WORKFLOW

### Arquitetura do fluxo:
```
Mensagem WhatsApp
    ↓
[premium] Webhook
    ↓
[Evolution API- Take all] Parse payload
    ↓
[setar_user] Buscar perfil no Supabase
    ↓
[buscar_relatorios] Check relatórios pendentes
    ↓
[Redis: firstGet] ← GARGALO #1: debounce via Redis
    ↓
[Switch] Classificar intenção
    ↓ (6 branches)
    ├── registrar_gasto → Prompt financeiro → AI Agent
    ├── buscar_gasto → Prompt busca → AI Agent
    ├── editar_gasto → Prompt edição → AI Agent → Tool editar_financeiro
    ├── excluir2 → Prompt exclusão → AI Agent → Tool excluir_financeiro
    ├── prompt_editar1 → Prompt edição evento → AI Agent → Tool editar_eventos
    └── prompt_excluir → Prompt exclusão evento → AI Agent → Tool excluir_evento
```

### Os 17 nodes Redis no workflow:
```
Redis Chat Memory  — memória da conversa do AI Agent
Redis1            — buscar id_user
firstGet          — debounce (primeira leitura)
mediumGet         — debounce (leitura intermediária)
lastGet           — debounce (última leitura)
lastGet1-10       — mais leituras de debounce
pushRedisMessage  — gravar mensagem no debounce
Redis3,Redis,Redis2,Redis6,Redis8,Redis10,Redis11 — deletar chaves de debounce
Redis4            — limpar memória de chat
Redis Chat Memory7 — ler histórico de chat
```

### GARGALO #1: Redis ENOTFOUND
- **17 nodes Redis** no workflow
- Redis Cloud está fora (`ENOTFOUND redis-13781.crce181.sa-east-1-2.ec2.redns.redis-cloud.com`)
- Cada node Redis que falha adiciona latência (timeout ou erro silencioso)
- O debounce system depende 100% do Redis — sem ele, perde funcionalidade de agrupar mensagens

### GARGALO #2: AI Agent chama sub-webhooks
- Editar/excluir eventos usa `httpRequestTool` que faz POST para **outro webhook** no mesmo n8n
- Fluxo: AI Agent → HTTP POST → Webhook → Processamento → Resposta
- Isso cria uma requisição HTTP extra + processamento de outro workflow
- Para editar evento: `AI Agent → editar_eventos webhook → busca no Supabase → UPDATE → resposta`

### GARGALO #3: Redis Chat Memory para AI Agent
- O AI Agent usa `memoryRedisChat` para manter contexto da conversa
- TTL de 300 segundos (5 min)
- Com Redis down: o Agent não tem memória → perde contexto → pode tomar decisões piores
- Também adiciona latência tentando conectar

### Soluções para os gargalos:

**Para Redis:**
1. Verificar se o plano Redis Cloud expirou (redis-13781.crce181)
2. Se expirou: criar novo Redis gratuito (Upstash, Railway, ou Redis Cloud free tier)
3. Alternativa: usar Redis local no server (apt install redis-server) — zero latência

**Para latência de edição de eventos:**
1. Em vez de sub-webhook, fazer UPDATE direto no Supabase dentro do mesmo workflow
2. Adicionar botões de edição/exclusão na criação (elimina a busca)
3. Timeout de 15s no AI Agent para evitar travamentos

**Para debounce:**
1. Sem Redis, considerar debounce via n8n Wait node + Supabase (mais lento mas funcional)
2. Ou: configurar Redis local que nunca vai estar ENOTFOUND

---

## RESUMO: ONDE ESTÁ O REDIS CLOUD

**Host:** `redis-13781.crce181.sa-east-1-2.ec2.redns.redis-cloud.com`
**Serviço:** Redis Cloud (redis.io/cloud) — provavelmente free tier
**Status:** ENOTFOUND — DNS não resolve
**Provável causa:** Plano gratuito expirou ou instância foi deletada por inatividade

**Para verificar:** Acesse https://app.redis.io com a conta que criou o Redis e verifique o status da subscription.
