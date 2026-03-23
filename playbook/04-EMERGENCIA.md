# Quando Algo Da Errado

## Nivel 1: Aviso — *validate-prod retornou ISSUES_FOUND

**Significa**: Problemas menores encontrados. PROD funciona mas tem algo a corrigir.

**Exemplos**: pinData residual, warnings nos logs, node com timeout baixo.

**O que fazer**:

```
1. Ler o relatorio de validacao:
   → guardian-deploy/output/deploys/{date}-post-deploy-validation.md

2. Para cada issue:
   → E urgente? Corrigir agora
   → Pode esperar? Anotar para proxima sprint

3. Monitorar logs por 30 minutos:
   → ssh -i ~/.ssh/totalassistente root@188.245.190.178
   → docker logs totalassistente-n8n --tail 100 --since 30m

4. Se nao piorar: OK, monitorar nas proximas horas
```

---

## Nivel 2: Critico — *validate-prod retornou CRITICAL_FAILURE

**Significa**: Problema grave. PROD pode estar quebrado.

**Exemplos**: URL de DEV em PROD, credential errada, WhatsApp trigger fake, container down.

### Decisao rapida: corrigir ou rollback?

```
CORRIGIR se:
  → Sao poucas correcoes (1-3 itens)
  → Voce sabe exatamente o que faltou
  → O sistema ainda funciona parcialmente

ROLLBACK se:
  → Sao muitas correcoes
  → Voce nao sabe o que deu errado
  → O sistema esta completamente fora
  → Usuarios estao sendo afetados AGORA
```

### Caminho A: Corrigir

```
1. Ler o relatorio — quais itens falharam?

2. Para cada item critico:
   → Se URL de DEV: acessar N8N PROD, editar o node manualmente, trocar a URL
   → Se credential: acessar N8N PROD, editar o node, selecionar credential correta
   → Se WhatsApp trigger: editar Main workflow em PROD, remover fake, adicionar real

3. Apos corrigir:
   @guardian
   *validate-prod
   → Deve retornar ALL_CLEAR agora

4. Se ainda CRITICAL_FAILURE: ir para Caminho B (rollback)
```

### Caminho B: Rollback

```
╔═══════════════════════════════════════════════╗
║  DIGA: "RESTAURAR GOLDEN BACKUP"              ║
║                                                ║
║  Backup: GOLDEN_BACKUP_20260213 (950MB)        ║
║  Local: /home/totalAssistente/backups/          ║
║  Restaura: banco + dados N8N + workflows       ║
╚═══════════════════════════════════════════════╝
```

**Apos rollback**:

```
1. Verificar que PROD voltou ao normal:
   @guardian
   *validate-prod

2. Entender o que deu errado:
   → Reler o checklist: qual item voce pulou ou errou?
   → Reler o diff: tinha algo inesperado?

3. Corrigir o problema no DEV primeiro

4. Recomecar a esteira do zero:
   *snapshot pre-fix-{problema}
   (corrigir)
   *snapshot pos-fix-{problema}
   *diff --latest
   ... (seguir esteira normal)
```

---

## Nivel 3: Panico — Sistema fora do ar

**Significa**: Usuarios nao conseguem usar o Total Assistente.

### Acao imediata (primeiros 2 minutos)

```
1. SSH para PROD:
   ssh -i ~/.ssh/totalassistente root@188.245.190.178

2. Verificar containers:
   docker ps

3. Se container esta DOWN:
   docker compose up -d
   (isso reinicia o que caiu)

4. Se TODOS estao UP mas N8N nao responde:
   docker logs totalassistente-n8n --tail 50
   (ver o que esta acontecendo)

5. Se o problema e o workflow:
   RESTAURAR GOLDEN BACKUP
```

### Acao secundaria (proximos 10 minutos)

```
6. Apos sistema voltar:
   @guardian
   *validate-prod

7. Verificar que WhatsApp esta funcionando:
   → Enviar mensagem de teste para o bot
   → Verificar se responde

8. Monitorar logs por 30 minutos:
   docker logs totalassistente-n8n -f --since 5m
```

### Pos-mortem (proximo dia)

```
9. Documentar o que aconteceu:
   → O que voce mudou
   → O que quebrou
   → Como resolveu
   → O que fazer diferente na proxima vez

10. Atualizar os data files se necessario:
    → Novo pattern de URL? → deploy-rules.yaml
    → Nova credential? → prod-credential-map.yaml
    → Novo workflow? → workflow-id-map.yaml
```

---

## Contatos e Recursos

| Recurso | Onde |
|---------|------|
| SSH PROD | `ssh -i ~/.ssh/totalassistente root@188.245.190.178` |
| N8N DEV | `http://76.13.172.17:5678` |
| N8N PROD | `https://n8n.totalassistente.com.br` |
| Golden Backup | `/home/totalAssistente/backups/GOLDEN_BACKUP_20260213/` |
| Deploy doc | `/home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md` |
| Logs N8N | `docker logs totalassistente-n8n --tail 100` |
| Logs Worker | `docker logs totalassistente-n8n-worker --tail 100` |
| Logs Webhook | `docker logs totalassistente-n8n-webhook --tail 100` |
| Restart tudo | `docker compose up -d` (na pasta do compose) |

---

## Prevencao: como evitar emergencias

| Causa | Prevencao |
|-------|-----------|
| URL de DEV em PROD | SEMPRE rodar `*pre-deploy` |
| Credential errada | SEMPRE verificar checklist |
| WhatsApp quebrado | SEMPRE verificar trigger no checklist |
| Deploy com bug | SEMPRE rodar `*audit-spec` antes |
| Nao saber o que mudou | SEMPRE tirar snapshots |
| Nao saber como reverter | SEMPRE ter backup atualizado |

> A melhor emergencia e aquela que nunca acontece.
> Siga a esteira. Sem atalhos.
