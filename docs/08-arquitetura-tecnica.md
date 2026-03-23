# Arquitetura do Squad guardian-deploy

## Visao Geral

```
                    +---------------------+
                    |    @guardian (Vigil) |
                    |   Copiloto de Deploy |
                    +----------+----------+
                               |
              +----------------+----------------+
              |                |                |
      DIFF-CHECK        SPEC-AUDITOR      PRE-DEPLOY
              |                |                |
     *snapshot            *spec           *pre-deploy
     *diff             *audit-spec       *checklist
     *versions                           *validate-prod
              |                |                |
              v                v                v
     data/snapshots/    output/specs/    output/deploys/
     output/diffs/      output/audits/
```

## Componentes (34 arquivos)

### Nucleo

| Arquivo | Tipo | Funcao |
|---------|------|--------|
| `squad.yaml` | Manifesto | Configuracao do squad, componentes, guardrails, dependencias |
| `agents/guardian.md` | Agente | Vigil — persona, comandos, constitution, deploy_knowledge |
| `README.md` | Documentacao | Resumo de uso |
| `.synapse/manifest` | Synapse | Integracao com o motor de contexto (L5) |
| `scripts/activate-squad.sh` | Script | Inicializacao do squad no terminal |

### Tasks (6)

| Task | Comando | Elicit | Input Principal | Output |
|------|---------|--------|-----------------|--------|
| `snapshot-dev.md` | `*snapshot` | true | N8N DEV API (GET) | `data/snapshots/{dir}/*.json` |
| `diff-versions.md` | `*diff` | true | Dois snapshots locais | `output/diffs/{date}-diff-*.md` |
| `create-spec.md` | `*spec` | true | Descricao do usuario | `output/specs/{date}-spec-*.md` |
| `audit-spec.md` | `*audit-spec` | true | Spec .md | `output/audits/{date}-spec-audit-*.md` |
| `generate-deploy-checklist.md` | `*pre-deploy` | false | JSONs DEV + PROD + regras | `output/deploys/{date}-deploy-checklist.md` |
| `validate-post-deploy.md` | `*validate-prod` | true | Export PROD via @analisador | `output/deploys/{date}-post-deploy-validation.md` |

### Workflows (4)

| Workflow | Steps | Pausas Manuais | Quando Usar |
|----------|-------|----------------|-------------|
| `full-lifecycle.yaml` | 9 | 2 (mudancas + deploy) | Ciclo completo start-to-finish |
| `diff-check.yaml` | 2 | 0 | Apenas snapshot + diff |
| `spec-audit.yaml` | 2 | 0 | Apenas spec + teste |
| `pre-deploy.yaml` | 3 | 1 (deploy) | Checklist + validacao |

### Data Files (5)

| Arquivo | Funcao | Atualizacao |
|---------|--------|-------------|
| `environments.yaml` | Mapa DEV vs PROD completo (IPs, URLs, workflows, containers) | Verificado ao vivo 2026-03-23 |
| `deploy-rules.yaml` | Regras de deploy machine-readable (URLs, credentials, WhatsApp) | Derivado de DEPLOY_N8N_WORKFLOWS.md |
| `prod-credential-map.yaml` | Mapeamento credential DEV -> PROD | Atualizar quando credentials mudam |
| `workflow-id-map.yaml` | Mapeamento workflow name -> PROD ID (com dev_id) | Verificado ao vivo 2026-03-23 |
| `snapshot-registry.yaml` | Registro append-only de snapshots capturados | Automatico (gerenciado por *snapshot) |

### Templates (6) e Checklists (2)

Templates usam `{placeholder}` syntax para preenchimento dinamico.
Checklists usam `[ ]` checkboxes para verificacao interativa.

---

## Modelo de Seguranca — 7 Camadas

```
Camada 1: AGENTE       Persona inclui "EU PROTEJO O DEPLOY. EU NUNCA EXECUTO."
Camada 2: CONSTITUTION  6 artigos NON-NEGOTIABLE no guardian_constitution
Camada 3: SQUAD.YAML   guardrails mode: "dev-read-prod-readonly", severity: BLOCK
Camada 4: API POLICY   N8N DEV: somente GET. PROD: somente via @analisador SSH read-only
Camada 5: OUTPUT        Escrita somente em output/ e data/snapshots/
Camada 6: WORKFLOW      Pausas manuais onde o humano executa (nunca automatico)
Camada 7: CHECKLIST     guardrails-checklist.md verificado antes de cada acao
```

Cada camada assume que as anteriores falharam. Se a persona nao impedir, a constitution impede. Se a constitution falhar, o squad.yaml bloqueia. E assim por diante.

### Politica de Acesso

| Recurso | Acesso | Via | Operacoes Permitidas |
|---------|--------|-----|---------------------|
| N8N DEV API | Direto | HTTP GET | Listar workflows, ver workflow, ver execucoes |
| N8N PROD | Delegado | @analisador SSH | docker ps, docker logs, export:workflow --all |
| JSONs PROD local | Direto | File read | Ler JSONs em /home/totalAssistente/jsonsProd/ |
| JSONs DEV local | Direto | File read | Ler JSONs em /home/AIOS-Total/totalAssistente/jsons/ |
| Supabase | Nenhum | — | Guardian nao acessa Supabase diretamente |
| GitHub | Nenhum | — | Guardian nao faz push/commit |

### O que esta BLOQUEADO (permanentemente)

- `PUT/POST/DELETE` em qualquer N8N API
- SSH direto para producao
- Executar deploy automaticamente
- Modificar workflows em qualquer ambiente
- Enviar mensagens WhatsApp
- Escrever em Supabase
- `docker stop/restart/rm`
- `git push/commit`

---

## Mapa de Delegacao

O guardian-deploy depende de 4 squads existentes. Ele NUNCA reimplementa o que eles ja fazem.

```
guardian-deploy (Vigil)
    |
    |-- testador-n8n (Watson)
    |   Quando: *audit-spec precisa testar features no DEV
    |   Comandos: *simulate, *test-webhook, *validate
    |   Acesso: N8N DEV (read-write para testes)
    |
    |-- deploy-review (Sentinel/Delta)
    |   Quando: *pre-deploy precisa de diff completo DEV vs PROD
    |   Comandos: *review, *quick-diff
    |   Acesso: Ambientes DEV e PROD (read-only)
    |
    |-- auditor-360 (Lupa)
    |   Quando: *audit-spec precisa testar features especificas
    |   Comandos: *audit, *audit-category
    |   Acesso: N8N DEV + Supabase (read-write para dados de teste)
    |
    |-- analisador-n8n (Sherlock)
    |   Quando: *validate-prod precisa ler PROD
    |   Comandos: *check-logs, *system-status, export workflows
    |   Acesso: PROD via SSH read-only (whitelist de comandos)
```

---

## Fluxo de Dados

### Snapshot

```
N8N DEV API --GET--> JSON workflows --limpa pinData--> data/snapshots/{dir}/
                                                            |
                                                   manifest.md (hashes)
                                                            |
                                                   snapshot-registry.yaml (append)
```

### Diff

```
data/snapshots/v1/*.json  --compara-->  output/diffs/{date}-diff-*.md
data/snapshots/v2/*.json  --estrutural--
```

### Deploy Checklist (fluxo mais complexo)

```
JSONs DEV (snapshot)  ----+
                           |
JSONs PROD (local)    ----+--> SCAN ENGINE --> output/deploys/{date}-deploy-checklist.md
                           |
deploy-rules.yaml     ----+    5 Scans:
prod-credential-map   ----+    1. URLs de DEV
workflow-id-map       ----+    2. Credential IDs
DEPLOY_N8N_WORKFLOWS  ----+    3. WhatsApp trigger fake
                               4. pinData
                               5. Verificacoes adicionais
```

### Validacao Pos-Deploy

```
@analisador --SSH read-only--> PROD
    |
    |-- docker ps (containers)
    |-- docker logs (erros)
    |-- n8n export:workflow --all (JSONs PROD atuais)
    |
    +--> SCAN POS-DEPLOY --> output/deploys/{date}-post-deploy-validation.md
         (mesmos 5 scans do checklist, agora nos JSONs de PROD)
```

---

## Versionamento

| Arquivo | Versao Atual | Semantica |
|---------|-------------|-----------|
| squad.yaml | 1.0.0 | MAJOR: breaking changes, MINOR: nova task/workflow, PATCH: fixes |
| workflow-id-map.yaml | 2.0.0 | Atualizado para incluir dev_id + verificacao ao vivo |
| deploy-rules.yaml | 1.0.0 | Derivado de DEPLOY_N8N_WORKFLOWS.md |
| prod-credential-map.yaml | 1.0.0 | Atualizar quando credentials mudam |
| environments.yaml | 1.0.0 | Verificado ao vivo 2026-03-23 |
