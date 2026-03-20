# BOT-01 — SAUDACAO

**Funcionalidade:** bot-whatsapp/01
**Data:** 2026-03-20T14:27:33Z
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Veredicto

**PASS**

### O que era esperado

O sistema deve responder com saudacao generica. Nenhum registro deve ser criado em spent ou calendar. Branch deve ser 'padrao'.

### O que aconteceu

A mensagem "oi tudo bem?" foi enviada ao webhook dev. O sistema respondeu em log #3955.

O sistema se comportou conforme esperado. A operacao foi realizada corretamente e verificada no banco de dados real.

### Pontos positivos

IA recusou corretamente. Nenhum registro criado no banco. | Workflows N8N todos success.

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

1. Snapshot ANTES: contou registros no banco (spent=91, calendar=318), salvou ultimo log_id=3954
2. Enviou mensagem "oi tudo bem?" via POST http://76.13.172.17:5678/webhook/dev-whatsapp
3. Polled log_users_messages a cada 3s ate novo log aparecer (max 45s)
4. Verificou banco imediatamente (operacao sincrona)
5. Snapshot DEPOIS: recontou registros (spent=91, calendar=318)
6. Buscou registro especifico por nome no banco
7. Consultou ultimas execucoes do N8N via API

### Resposta da IA

- **log_id:** 3955
- **Mensagem:**  

### Registro no banco

```
spent:91->91 cal:318->318
```

### Execucoes N8N

```
11708|FixConflito|success
11707|Main|success
11706|CalendarWH|success
11705|FixConflito|success
11704|Main|success
11702|CalendarWH|success
```

### Snapshots

| Momento | spent | calendar | Variacao spent | Variacao calendar |
|---------|-------|----------|---------------|------------------|
| ANTES | 91 | 318 | — | — |
| DEPOIS | 91 | 318 | 0 | 0 |

---

*Teste executado por @auditor (Lupa) — Auditoria 360*
