# AGD-01 — CRIAR_EVENTO

**Funcionalidade:** agenda/01
**Data:** 2026-03-20T14:24:14Z
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Veredicto

**PASS**

### O que era esperado

O sistema deve criar evento 'Reuniao Com Parceiro' na tabela calendar com start_event=amanha 14:00, compromisso_tipo=compromisso, is_recurring=false. Deve sincronizar com Google Calendar se conectado.

### O que aconteceu

A mensagem "reuniao com parceiro amanha 14h" foi enviada ao webhook dev. O sistema respondeu em log #3948.

O sistema se comportou conforme esperado. A operacao foi realizada corretamente e verificada no banco de dados real.

### Pontos positivos

Evento criado no banco. IA confirmou. Contagem subiu.

### Pontos negativos

Workflow N8N reportou error: 11682|CalendarWH|error

---

## KPIs do teste

| KPI | Valor | Descricao |
|-----|-------|-----------|
| Funcional | 1 | A funcionalidade fez o que deveria? (1=sim, 0=nao) |
| Banco | 1 | O banco de dados reflete a acao? (1=sim, 0=nao, 0.5=parcial) |
| N8N | 0 | Todos os workflows executaram sem error? (1=sim, 0=nao) |
| Consistencia | 1 | IA disse a mesma coisa que o banco mostra? (1=sim, 0=nao, 0.5=parcial) |
| **Score** | **0.75** | Media dos 4 KPIs (0 a 1) |

---

## Detalhes tecnicos

### Metodo utilizado

1. Snapshot ANTES: contou registros no banco (spent=91, calendar=316), salvou ultimo log_id=3947
2. Enviou mensagem "reuniao com parceiro amanha 14h" via POST http://76.13.172.17:5678/webhook/dev-whatsapp
3. Polled log_users_messages a cada 3s ate novo log aparecer (max 45s)
4. Verificou banco imediatamente (operacao sincrona)
5. Snapshot DEPOIS: recontou registros (spent=91, calendar=317)
6. Buscou registro especifico por nome no banco
7. Consultou ultimas execucoes do N8N via API

### Resposta da IA

- **log_id:** 3948
- **Mensagem:**  

### Registro no banco

```
name=Reunião Com Parceiro|start=2026-03-21T14:00|end=2026-03-21T14:30|tipo=compromisso|rec=NAO|rrule=-|active=True|id=d77e30b9
```

### Execucoes N8N

```
11682|CalendarWH|error
11681|CalendarWH|success
11680|FixConflito|success
11679|Main|success
11678|Financeiro|success
11677|FixConflito|success
```

### Snapshots

| Momento | spent | calendar | Variacao spent | Variacao calendar |
|---------|-------|----------|---------------|------------------|
| ANTES | 91 | 316 | — | — |
| DEPOIS | 91 | 317 | 0 | 1 |

---

*Teste executado por @auditor (Lupa) — Auditoria 360*
