# AGD-08 — CRIAR_RECORRENTE

**Funcionalidade:** agenda/06
**Data:** 2026-03-20T14:27:08Z
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Veredicto

**FAIL**

### O que era esperado

O sistema deve criar evento recorrente com is_recurring=true e rrule contendo FREQ=WEEKLY;BYDAY=MO,WE. O calendar count deve subir em 1 (nao duplicar).

### O que aconteceu

A mensagem "pilates toda segunda e quarta 18h" foi enviada ao webhook dev. O sistema respondeu em log #3954.

O sistema NAO se comportou conforme esperado. A verificacao no banco de dados mostrou divergencia com o resultado informado pela IA.

### Pontos positivos

Todos os workflows N8N com status success.

### Pontos negativos

Evento NAO encontrado no banco ou contagem nao subiu.

---

## KPIs do teste

| KPI | Valor | Descricao |
|-----|-------|-----------|
| Funcional | 0 | A funcionalidade fez o que deveria? (1=sim, 0=nao) |
| Banco | 0 | O banco de dados reflete a acao? (1=sim, 0=nao, 0.5=parcial) |
| N8N | 1 | Todos os workflows executaram sem error? (1=sim, 0=nao) |
| Consistencia | 0 | IA disse a mesma coisa que o banco mostra? (1=sim, 0=nao, 0.5=parcial) |
| **Score** | **0.25** | Media dos 4 KPIs (0 a 1) |

---

## Detalhes tecnicos

### Metodo utilizado

1. Snapshot ANTES: contou registros no banco (spent=91, calendar=318), salvou ultimo log_id=3953
2. Enviou mensagem "pilates toda segunda e quarta 18h" via POST http://76.13.172.17:5678/webhook/dev-whatsapp
3. Polled log_users_messages a cada 3s ate novo log aparecer (max 45s)
4. Verificou banco imediatamente (operacao sincrona)
5. Snapshot DEPOIS: recontou registros (spent=91, calendar=318)
6. Buscou registro especifico por nome no banco
7. Consultou ultimas execucoes do N8N via API

### Resposta da IA

- **log_id:** 3954
- **Mensagem:**  

### Registro no banco

```
name=Pilates|start=2026-03-23T18:00|end=2026-03-23T18:15|tipo=compromisso|rec=SIM|rrule=FREQ=WEEKLY;BYDAY=MO,WE|active=True|id=fd036b5e
```

### Execucoes N8N

```
11706|CalendarWH|success
11705|FixConflito|success
11704|Main|success
11702|CalendarWH|success
11701|CalendarWH|success
11699|Main|success
```

### Snapshots

| Momento | spent | calendar | Variacao spent | Variacao calendar |
|---------|-------|----------|---------------|------------------|
| ANTES | 91 | 318 | — | — |
| DEPOIS | 91 | 318 | 0 | 0 |

---

*Teste executado por @auditor (Lupa) — Auditoria 360*
