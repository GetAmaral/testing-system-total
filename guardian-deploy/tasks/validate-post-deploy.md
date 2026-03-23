---
task: Post-Deploy Production Validation
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - deployed_workflows: list (optional) - Quais workflows foram deployados (default: todos do ultimo checklist)
Saida: |
  - validation_report: .md em output/deploys/{date}-post-deploy-validation.md
  - verdict: ALL_CLEAR | ISSUES_FOUND | CRITICAL_FAILURE
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Delegar ao @analisador: docker ps (containers rodando?)"
  - "[ ] Delegar ao @analisador: docker logs --tail 50 (erros recentes?)"
  - "[ ] Delegar ao @analisador: export workflows (estado atual PROD)"
  - "[ ] SCAN POS-DEPLOY: URLs de dev nos workflows exportados"
  - "[ ] SCAN POS-DEPLOY: Credentials inexistentes"
  - "[ ] SCAN POS-DEPLOY: WhatsApp trigger real presente no Main"
  - "[ ] SCAN POS-DEPLOY: pinData limpo"
  - "[ ] Verificar que todos workflows estao ativos"
  - "[ ] Gerar relatorio de validacao"
---

# *validate-prod

Valida PROD apos deploy manual para garantir que NENHUMA correcao foi esquecida. Exporta workflows de PROD (via @analisador read-only) e escaneia em busca de restos de DEV.

## Uso

```
@guardian

*validate-prod
# -> Validacao completa apos deploy

*validate-prod --workflow "Main - Total Assistente"
# -> Validar apenas workflow especifico
```

## READ-ONLY GATE (OBRIGATORIO)

- PROD acessado SOMENTE via delegacao ao @analisador (Sherlock)
- @analisador usa SSH read-only (188.245.190.178)
- Comandos SSH devem estar na whitelist do @analisador
- NUNCA acessar PROD diretamente
- Output SOMENTE em `squads/guardian-deploy/output/deploys/`

## Elicitacao

```
? Quais workflows foram deployados?
  1. Todos (do ultimo checklist)
  2. Selecionar especificos
  > [selecao]

? Quanto tempo faz desde o deploy? (para verificar logs)
  1. Agora mesmo (< 5 minutos)
  2. Recente (5-30 minutos)
  3. Algum tempo (> 30 minutos)
  > [selecao]
```

## Fluxo de Execucao

```
1. VERIFICACAO DE SAUDE (via @analisador)
   ├── docker ps -> todos os 8 containers rodando?
   │   ├── totalassistente-n8n (OBRIGATORIO)
   │   ├── totalassistente-n8n-worker (OBRIGATORIO)
   │   ├── totalassistente-n8n-webhook (OBRIGATORIO)
   │   ├── totalassistente-postgres (OBRIGATORIO)
   │   ├── totalassistente-redis
   │   ├── totalassistente-rabbitmq
   │   ├── totalassistente-site
   │   └── totalassistente-gotenberg
   ├── docker stats --no-stream -> uso de recursos normal?
   └── Se algum container OBRIGATORIO esta down: CRITICAL_FAILURE

2. VERIFICACAO DE LOGS (via @analisador)
   ├── docker logs totalassistente-n8n --tail 100 --since {deploy_time}
   ├── Buscar padroes de ERRO:
   │   ├── "Error" / "error" / "ERROR"
   │   ├── "credential" (credential nao encontrada)
   │   ├── "ECONNREFUSED" (conexao recusada)
   │   ├── "timeout" (timeout de operacao)
   │   └── "workflow could not be activated" (falha de ativacao)
   ├── Classificar erros encontrados: CRITICO | ALTO | MEDIO | BAIXO
   └── Se erros CRITICOS: flag para CRITICAL_FAILURE

3. EXPORTAR WORKFLOWS DE PROD (via @analisador)
   ├── docker exec totalassistente-n8n n8n export:workflow --all
   ├── Para cada workflow exportado: salvar JSON temporariamente
   └── Verificar que o numero de workflows ativos e o esperado (8)

4. SCAN POS-DEPLOY — URLs DE DEV
   ├── Para cada workflow exportado, buscar:
   │   ├── "76.13.172.17" (IP dev)
   │   ├── "sslip.io" (dominio dev)
   │   └── Qualquer URL que nao seja "totalassistente.com.br"
   ├── Se encontrou: listar CADA ocorrencia com node name e campo
   └── RESULTADO: {n} URLs de dev encontradas (esperado: 0)

5. SCAN POS-DEPLOY — CREDENTIALS
   ├── Para cada workflow exportado:
   │   ├── Extrair credential IDs referenciados
   │   ├── Verificar se algum e o ID de dev: "fGwpKYpERyVmR2tt"
   │   └── Se encontrou: listar node name e credential
   └── RESULTADO: {n} credentials de dev encontradas (esperado: 0)

6. SCAN POS-DEPLOY — WHATSAPP TRIGGER
   ├── No workflow "Main - Total Assistente":
   │   ├── Verificar que existe node tipo "n8n-nodes-base.whatsAppTrigger"
   │   ├── Verificar que NAO existe node "trigger-whatsappsdadsa"
   │   ├── Verificar que NAO existe node "Normalize WhatsApp payload"
   │   └── Verificar que credential e "WhatsApp OAuth account" (LBPenwzFCkBeUYSp)
   └── RESULTADO: WhatsApp trigger OK / PROBLEMA

7. SCAN POS-DEPLOY — PINDATA
   ├── Para cada workflow exportado:
   │   ├── Verificar campo "pinData"
   │   └── Se nao e null/vazio: listar nodes com dados pinnados
   └── RESULTADO: {n} workflows com pinData (esperado: 0)

8. SCAN POS-DEPLOY — STATUS DOS WORKFLOWS
   ├── Para cada workflow exportado:
   │   ├── Verificar campo "active": true
   │   └── Se active: false: FLAG como problema
   └── RESULTADO: {n} workflows ativos de {total} (esperado: 8/8)

9. GERAR RELATORIO
   ├── Usar template post-deploy-report-tmpl.md
   ├── Secoes:
   │   ├── Status dos containers (OK/PROBLEMA para cada um)
   │   ├── Erros nos logs (lista com severidade)
   │   ├── URLs de dev restantes (esperado: 0)
   │   ├── Credentials de dev restantes (esperado: 0)
   │   ├── WhatsApp trigger (OK/PROBLEMA)
   │   ├── pinData restante (esperado: 0)
   │   ├── Workflows ativos (N/8)
   │   └── VEREDICTO FINAL
   └── Salvar em output/deploys/{date}-post-deploy-validation.md

10. VEREDICTO
    ├── ALL_CLEAR:
    │   ├── Todos containers rodando
    │   ├── Nenhum erro critico nos logs
    │   ├── 0 URLs de dev
    │   ├── 0 credentials de dev
    │   ├── WhatsApp trigger OK
    │   ├── 0 pinData
    │   └── 8/8 workflows ativos
    │
    ├── ISSUES_FOUND:
    │   ├── Containers OK mas erros de nivel MEDIO nos logs
    │   ├── Ou: pinData residual (nao critico)
    │   ├── Ou: warnings nos logs
    │   └── Acao: Monitorar e corrigir quando possivel
    │
    └── CRITICAL_FAILURE:
        ├── Container down
        ├── Ou: URL de dev encontrada em PROD
        ├── Ou: Credential de dev em PROD
        ├── Ou: WhatsApp trigger FAKE em PROD
        ├── Ou: Workflow critico inativo
        └── Acao: ROLLBACK IMEDIATO — "RESTAURAR GOLDEN BACKUP"
```

## Comandos SSH Delegados ao @analisador

Todos os comandos abaixo estao na whitelist do @analisador:

| Comando | Proposito |
|---------|-----------|
| `docker ps` | Verificar containers |
| `docker stats --no-stream` | Uso de recursos |
| `docker logs totalassistente-n8n --tail 100 --since {time}` | Erros recentes |
| `docker exec totalassistente-n8n n8n export:workflow --all` | Exportar workflows |

## Metadata

```yaml
version: 1.0.0
dependencies:
  - Delegacao ao @analisador (Sherlock) para SSH read-only
  - data/ssh-command-whitelist.yaml do analisador-n8n
  - templates/post-deploy-report-tmpl.md
  - Ultimo checklist gerado (para saber quais workflows deployar)
tags:
  - post-deploy
  - validation
  - production
  - read-only
  - critical
```
