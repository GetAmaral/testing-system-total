# Validacao Pos-Deploy — PROD

**Data**: {date}
**Validado por**: Vigil (Guardian) via @analisador (Sherlock)

---

## Veredicto

```
{emoji} {ALL_CLEAR|ISSUES_FOUND|CRITICAL_FAILURE} — {justificativa}
```

---

## Status dos Containers

| Container | Status | Observacao |
|-----------|--------|------------|
| totalassistente-n8n | {UP/DOWN} | {obs} |
| totalassistente-n8n-worker | {UP/DOWN} | {obs} |
| totalassistente-n8n-webhook | {UP/DOWN} | {obs} |
| totalassistente-postgres | {UP/DOWN} | {obs} |
| totalassistente-redis | {UP/DOWN} | {obs} |
| totalassistente-rabbitmq | {UP/DOWN} | {obs} |
| totalassistente-site | {UP/DOWN} | {obs} |
| totalassistente-gotenberg | {UP/DOWN} | {obs} |

---

## Erros nos Logs (ultimos {n} minutos)

| Severidade | Mensagem | Container |
|------------|----------|-----------|
| {sev} | {mensagem} | {container} |

---

## Scan de URLs DEV Residuais

| Resultado | Esperado |
|-----------|----------|
| {n} URLs de dev encontradas | **0** |

{lista_detalhada_se_encontrou}

---

## Scan de Credentials DEV Residuais

| Resultado | Esperado |
|-----------|----------|
| {n} credentials de dev encontradas | **0** |

{lista_detalhada_se_encontrou}

---

## WhatsApp Trigger — Main Workflow

| Verificacao | Status |
|-------------|--------|
| Trigger real (whatsAppTrigger) presente | {OK/PROBLEMA} |
| Nodes fake ausentes | {OK/PROBLEMA} |
| Credential WhatsApp OAuth (LBPenwzFCkBeUYSp) | {OK/PROBLEMA} |

---

## pinData Residual

| Resultado | Esperado |
|-----------|----------|
| {n} workflows com pinData | **0** |

---

## Workflows Ativos

| Workflow | Active | Esperado |
|----------|--------|----------|
| {name} | {true/false} | true |

**Total**: {n_active}/8 workflows ativos

---

## Acao Recomendada

{acao_baseada_no_veredicto}

- **ALL_CLEAR**: Nenhuma acao necessaria. Deploy concluido com sucesso.
- **ISSUES_FOUND**: {lista_de_issues_e_acoes}
- **CRITICAL_FAILURE**: ROLLBACK IMEDIATO — "RESTAURAR GOLDEN BACKUP"

---

*Gerado pelo Guardian Deploy Squad - Vigil via @analisador (Sherlock)*
