# FIN-01 — CRIAR_GASTO

**Funcionalidade:** financeiro/01
**Data:** 2026-03-20T14:21:38Z
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Veredicto

**FAIL**

### O que era esperado

O sistema deve registrar um gasto de R$38 com nome 'Acai' na tabela spent, categoria Alimentacao, transaction_type=saida. A IA deve confirmar com 'Gasto registrado'. O registro deve aparecer no banco imediatamente.

### O que aconteceu

A mensagem "gastei 38 no acai" foi enviada ao webhook dev. O sistema respondeu em log #3936.

O sistema NAO se comportou conforme esperado. A verificacao no banco de dados mostrou divergencia com o resultado informado pela IA.

### Pontos positivos



### Pontos negativos

Registro NAO encontrado no banco ou contagem nao subiu. | Workflow N8N reportou error: 11644|Report|error
11641|Report|error

---

## KPIs do teste

| KPI | Valor | Descricao |
|-----|-------|-----------|
| Funcional | 0 | A funcionalidade fez o que deveria? (1=sim, 0=nao) |
| Banco | 0 | O banco de dados reflete a acao? (1=sim, 0=nao, 0.5=parcial) |
| N8N | 0 | Todos os workflows executaram sem error? (1=sim, 0=nao) |
| Consistencia | 0 | IA disse a mesma coisa que o banco mostra? (1=sim, 0=nao, 0.5=parcial) |
| **Score** | **0.0** | Media dos 4 KPIs (0 a 1) |

---

## Detalhes tecnicos

### Metodo utilizado

1. Snapshot ANTES: contou registros no banco (spent=88, calendar=316), salvou ultimo log_id=3935
2. Enviou mensagem "gastei 38 no acai" via POST http://76.13.172.17:5678/webhook/dev-whatsapp
3. Polled log_users_messages a cada 3s ate novo log aparecer (max 45s)
4. Verificou banco imediatamente (operacao sincrona)
5. Snapshot DEPOIS: recontou registros (spent=88, calendar=316)
6. Buscou registro especifico por nome no banco
7. Consultou ultimas execucoes do N8N via API

### Resposta da IA

- **log_id:** 3936
- **Mensagem:**  

### Registro no banco

```
NOT_FOUND
```

### Execucoes N8N

```
11646|FixConflito|success
11645|Main|success
11644|Report|error
11643|FixConflito|success
11642|Main|success
11641|Report|error
```

### Snapshots

| Momento | spent | calendar | Variacao spent | Variacao calendar |
|---------|-------|----------|---------------|------------------|
| ANTES | 88 | 316 | — | — |
| DEPOIS | 88 | 316 | 0 | 0 |

---

*Teste executado por @auditor (Lupa) — Auditoria 360*
