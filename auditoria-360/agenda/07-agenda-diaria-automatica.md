# Metodologia de Auditoria — Agenda Diária Automática

**Funcionalidade:** `agenda/07-agenda-diaria-automatica`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### O que é

Envio automático da agenda do dia para o user via WhatsApp todas as manhãs. Apenas para users Premium.

### Caminho

```
Lembretes Total Assistente (b3xKlSunpwvC4Vwh):
  → Schedule Trigger (1 min)1 — segundo schedule trigger
    → Get Events (in 30 min) — SELECT calendar WHERE start_event BETWEEN now AND now+30min
    → Loop Over Items1 — para cada evento próximo
      → Get a row2/3 (profiles) — busca dados do user
      → If3/If4 — user Premium?
        ├── SIM → Monta mensagem de agenda
          → HTTP Request — send agenda template (WhatsApp template)
          → Create a row (log_total: lembrete_automatico)
        └── NÃO → Skip
```

### Nós relevantes

| Nó | Função |
|----|--------|
| `Schedule Trigger (1 min)1` | Timer que roda a cada 1 minuto |
| `Get Events (in 30 min)` / `Get Events (in 30 min)1` | Busca eventos próximos |
| `HTTP Request — send agenda template` | Envia template WhatsApp |
| `If5` / `If6` | Verifica se user é Premium |

### Limitação de teste

Watson **não pode esperar** o schedule trigger disparar organicamente (seria preciso ter evento exatamente no horário certo). Estratégias:
1. Criar evento com start_event = agora + 25min → esperar 5min → verificar se lembrete foi enviado
2. Verificar log_total por entradas `lembrete_automatico` recentes
3. Verificar execuções do workflow Lembretes

---

## 2. Algoritmo de execução

```
PASSO 1 — Verificar execuções recentes do Lembretes
  GET /executions?workflowId=b3xKlSunpwvC4Vwh&limit=10
  → Quantas success? Quantas error?

PASSO 2 — Verificar log_total por lembretes automáticos
  GET /log_total?acao=eq.lembrete_automatico&user_id=eq.{user_id}&order=created_at.desc&limit=5
  → Existem entradas recentes?

PASSO 3 — (Opcional) Criar evento próximo e esperar disparo
  3.1  Criar evento com start = agora + 25min
  3.2  Esperar 30min
  3.3  Verificar log_total: lembrete_automatico apareceu?
  3.4  Verificar remembered=true no calendar

PASSO 4 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Schedule rodando | Execuções recentes do Lembretes = success | Sem execuções ou errors |
| 2 | Lembretes enviados | log_total tem lembrete_automatico | Sem entradas |
| 3 | Apenas Premium | Lembretes só pra users com plano Premium | Enviou pra Standard |
| 4 | Horário correto | Lembrete disparou ~30min antes do evento | Muito cedo ou muito tarde |

---

## 4. Protocolo de diagnóstico de erros

```
CAMADA 1 — SCHEDULE: Trigger está ativo e rodando?
CAMADA 2 — QUERY: Get Events (in 30 min) retornou eventos?
CAMADA 3 — PLANO: User é Premium?
CAMADA 4 — TEMPLATE: WhatsApp template enviou? HTTP 200?
CAMADA 5 — LOG: log_total registrou?
```

---

## 5. Testes

**🟢 Quick (2 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| DAILY-Q1 | Verificar schedule ativo | Execuções recentes do workflow Lembretes |
| DAILY-Q2 | Verificar log_total | Existem lembrete_automatico recentes |

**🟡 Broad (Quick + 3 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| DAILY-B1 | Criar evento daqui 25min | Lembrete dispara? |
| DAILY-B2 | Verificar remembered=true | Após lembrete, campo atualizado |
| DAILY-B3 | User Standard | NÃO recebe lembrete automático |

**🔴 Complete (Broad + 2 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| DAILY-C1 | Múltiplos eventos no mesmo horário | Recebe 1 lembrete ou múltiplos? |
| DAILY-C2 | Recorrente com próximo fire | next_fire_at dispara e avança |

---

## 6. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Horário configurável pelo user | Personalização |
| Logar "agenda_diaria_enviada" no log_total | Diferenciar de lembrete individual |
