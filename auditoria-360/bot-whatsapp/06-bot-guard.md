# Metodologia de Auditoria — Bot Guard (Anti-Loop & Anti-Spam)

**Funcionalidade:** `bot-whatsapp/06-bot-guard`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp → Main (webhook trigger)
  → Check Message Age (code) — rejeita msgs >2 min
  → Redis1 (redis) — verifica se user está em loop/bloqueio
  → If1 — bloqueado?
    ├── SIM → descarta mensagem (não processa)
    └── NÃO → segue fluxo normal
```

### Tabelas envolvidas

| Tabela | Banco | Função |
|--------|-------|--------|
| `bot_blocks` | Principal | Registro de bloqueios ativos |
| `bot_events` | Principal | Eventos de spam/loop detectados |
| `rate_limits` | Principal | Rate limiting por user |

### Nós no Main

| Nó | Tipo | Função |
|----|------|--------|
| `Check Message Age` | code | Calcula idade da mensagem. Se >2min → rejeita |
| `Redis1` | redis | Consulta flag de bloqueio no Redis |
| `If1` | if | Se bloqueado → não processa |
| `Redis` | redis | Seta flag de controle após processamento |

---

## 2. Endpoints de verificação

| Verificação | Query |
|-------------|-------|
| Bloqueios ativos | `GET /bot_blocks?select=*&user_id=eq.{user_id}` (Principal) |
| Eventos de spam | `GET /bot_events?select=*&user_id=eq.{user_id}&order=created_at.desc&limit=10` |
| Rate limits | `GET /rate_limits?select=*&order=created_at.desc&limit=10` |

---

## 3. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Verificar bot_blocks do user → BLOCKS_ANTES
  1.2  Verificar bot_events do user → EVENTS_ANTES
  1.3  Verificar rate_limits → RATES_ANTES
  1.4  Último log_id → LAST_LOG_ID

PASSO 2 — ENVIAR MENSAGEM(ns) — pode ser spam rápido

PASSO 3 — VERIFICAR COMPORTAMENTO
  3.1  Mensagem única: foi processada normalmente?
  3.2  Spam (5 msgs rápidas): foi bloqueado?
  3.3  Verificar bot_blocks: novo bloqueio criado?
  3.4  Verificar bot_events: evento de spam registrado?
  3.5  Verificar rate_limits: limite atingido?

PASSO 4 — REGISTRAR

CLEANUP — Se user foi bloqueado pelo teste:
  Verificar se desbloqueou sozinho (tempo)
  Ou DELETE /bot_blocks?user_id=eq.{user_id} (manual)
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Mensagem normal passa | 1 mensagem = processada | Bloqueada indevidamente |
| 2 | Spam bloqueado | 5+ msgs rápidas = bloqueio | Não bloqueou |
| 3 | Mensagem antiga rejeitada | Timestamp >2min = rejeitada | Processou msg velha |
| 4 | Evento registrado | bot_events tem registro do spam | Sem registro |
| 5 | Desbloqueio funciona | Após timeout, user desbloqueia | Permanece bloqueado |

---

## 5. Protocolo de diagnóstico de erros

```
CAMADA 1 — CHECK MESSAGE AGE: Rejeitou mensagem válida (timestamp ok)?
CAMADA 2 — REDIS: Flag de bloqueio estava setada quando não devia?
CAMADA 3 — BOT_BLOCKS: Registro existe mas não deveria?
CAMADA 4 — RATE_LIMITS: Threshold muito baixo/alto?
CAMADA 5 — DESBLOQUEIO: Tempo de bloqueio correto? Desbloqueou?
```

---

## 6. Testes

**🟢 Quick (2 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| GUARD-Q1 | 1 mensagem "oi" | Normal | Processada normalmente. Sem bloqueio. |
| GUARD-Q2 | Verificar bot_blocks | Estado | User de teste não está bloqueado |

**🟡 Broad (Quick + 4 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| GUARD-B1 | 3 mensagens em 5s | Spam leve | Todas processadas ou 3ª bloqueada? Documentar threshold |
| GUARD-B2 | 5 mensagens em 3s | Spam médio | Bloqueio ativado? bot_events registrado? |
| GUARD-B3 | Mensagem com timestamp de 5min atrás | Msg antiga | Rejeitada pelo Check Message Age |
| GUARD-B4 | Verificar rate_limits | Estado | Thresholds configurados |

**🔴 Complete (Broad + 3 testes):**

| ID | Input | Cenário | Verificação |
|----|-------|---------|-------------|
| GUARD-C1 | 10 mensagens em 5s | Spam pesado | Bloqueio definitivo? |
| GUARD-C2 | Esperar desbloqueio | Pós-bloqueio | Após X minutos, user desbloqueia? |
| GUARD-C3 | Verificar isolamento | Spam de user A não bloqueia user B | Bloqueio por user, não global |

---

## 7. Formato do log

```markdown
| ID | Msgs enviadas | Intervalo | Bloqueou? | bot_blocks | bot_events | Veredicto |
```

---

## 8. Problemas conhecidos

| Problema | Impacto |
|----------|---------|
| Spam de teste pode bloquear o user de teste | Precisa desbloquear manualmente |
| Threshold de bloqueio não documentado | Testar empiricamente |
| Check Message Age usa timestamp do payload | Timestamp simulado pode ser rejeitado |

---

## 9. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Documentar thresholds (X msgs em Y segundos = bloqueio) | Testes previsíveis |
| Logar motivo de rejeição ("msg antiga", "spam", "bloqueado") | Diagnóstico mais rápido |
| Endpoint de desbloqueio manual | Facilita cleanup pós-teste |
