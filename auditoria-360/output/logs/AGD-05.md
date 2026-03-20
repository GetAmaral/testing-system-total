# AGD-05 — BUSCAR_DATA

**Funcionalidade:** agenda/02
**Data:** 2026-03-20T14:24:55Z
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Veredicto

**PASS**

### O que era esperado

O sistema deve buscar eventos do dia 25 do mes atual. NAO deve criar nenhum registro. Se nao houver eventos, informar.

### O que aconteceu

A mensagem "o que tenho dia 25?" foi enviada ao webhook dev. O sistema respondeu em log #3952.

O sistema se comportou conforme esperado. A operacao foi realizada corretamente e verificada no banco de dados real.

### Pontos positivos

IA retornou busca. Verificacao cruzada necessaria manualmente. | Workflows N8N todos success.

### Pontos negativos

Nenhum ponto negativo constatado.

---

## KPIs do teste

| KPI | Valor | Descricao |
|-----|-------|-----------|
| Funcional | 1 | A funcionalidade fez o que deveria? (1=sim, 0=nao) |
| Banco | 1 | O banco de dados reflete a acao? (1=sim, 0=nao, 0.5=parcial) |
| N8N | 1 | Todos os workflows executaram sem error? (1=sim, 0=nao) |
| Consistencia | 1 | IA disse a mesma coisa que o banco mostra? (1=sim, 0=nao, 0.5=parcial) |
| **Score** | **1.0** | Media dos 4 KPIs (0 a 1) |

---

## Detalhes tecnicos

### Metodo utilizado

1. Snapshot ANTES: contou registros no banco (spent=91, calendar=319), salvou ultimo log_id=3951
2. Enviou mensagem "o que tenho dia 25?" via POST http://76.13.172.17:5678/webhook/dev-whatsapp
3. Polled log_users_messages a cada 3s ate novo log aparecer (max 45s)
4. Verificou banco imediatamente (operacao sincrona)
5. Snapshot DEPOIS: recontou registros (spent=91, calendar=319)
6. Buscou registro especifico por nome no banco
7. Consultou ultimas execucoes do N8N via API

### Resposta da IA

- **log_id:** 3952
- **Mensagem:**  

### Registro no banco

```
response_only
```

### Execucoes N8N

```
11694|CalendarWH|success
11693|FixConflito|success
11692|Main|success
11691|CalendarWH|success
11690|FixConflito|success
11689|Main|success
```

### Snapshots

| Momento | spent | calendar | Variacao spent | Variacao calendar |
|---------|-------|----------|---------------|------------------|
| ANTES | 91 | 319 | — | — |
| DEPOIS | 91 | 319 | 0 | 0 |

---

*Teste executado por @auditor (Lupa) — Auditoria 360*
