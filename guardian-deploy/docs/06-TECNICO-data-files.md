# Data Files e Mapeamentos

Todos os data files ficam em `guardian-deploy/data/`. Sao a base de conhecimento do squad.

---

## 1. environments.yaml — FONTE DA VERDADE

**Funcao**: Mapa completo DEV vs PROD verificado ao vivo. Referencia primaria para qualquer duvida sobre ambientes.

**Ultima verificacao**: 2026-03-23 (via API DEV + SSH PROD)

### Estrutura

```yaml
dev:
  vps:
    ip: "76.13.172.17"
    ssh_access: false              # NAO temos SSH para DEV
  n8n:
    url: "http://76.13.172.17:5678"
    version: "2.11.2"
    workflows: [6 workflows com IDs]
  supabase:
    ai_messages: { ref, url }     # DEV
    principal: { ref, url }       # PROD (read-only)
  urls_que_identificam_dev: [...]  # Patterns para scan
  whatsapp_trigger:
    type: "FAKE"
  test_user: { name, phone, user_id, email }

prod:
  vps:
    ip: "188.245.190.178"
    hostname: "total-assistente-02"
    ssh_access: true
  n8n:
    url: "https://n8n.totalassistente.com.br"
    version: "2.4.4"
    containers: [8 containers com status]
    workflows: [9 workflows com IDs e node counts]
  whatsapp_trigger:
    type: "REAL"
    credential_id: "LBPenwzFCkBeUYSp"

comparison: [tabela comparativa aspecto por aspecto]
workflow_id_mapping: [mapeamento DEV ID <-> PROD ID]
```

### Quando atualizar
- Quando mudar IP, URL ou dominio de qualquer VPS
- Quando adicionar/remover workflows
- Quando mudar versao do N8N
- Quando containers mudarem

---

## 2. deploy-rules.yaml — Regras de Deploy

**Funcao**: Versao machine-readable do `/home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md`. Usado pelo `*pre-deploy` para gerar checklist.

**Fonte original**: `DEPLOY_N8N_WORKFLOWS.md` (2026-02-13)

### Estrutura

```yaml
url_replacements:
  - pattern: "http://n8n-fcwk0sw4soscgsgs08g8gssk.76.13.172.17.sslip.io"
    replacement: "https://totalassistente.com.br"
    type: exact
  - pattern: "76.13.172.17"
    replacement: "totalassistente.com.br"
    type: contains

credential_swaps:
  - dev_id: "fGwpKYpERyVmR2tt"
    prod_id: "1ENA7UIm6ILehilJ"
    name: "Supabase account"

whatsapp_trigger:
  workflow: "Main - Total Assistente"
  severity: CRITICAL
  fake_nodes_to_remove: [3 nodes]
  real_trigger: { name, type, credential_name, credential_id }

workflows_to_skip:
  - name: "Service Message - 24 Hours"

cleanup:
  - field: "pinData"
  - field: "staticData"

execution_steps: [7 passos do deploy]
rollback: { trigger_phrase, backup_name }
```

### Quando atualizar
- Quando `DEPLOY_N8N_WORKFLOWS.md` mudar
- Quando novas URL patterns de DEV surgirem
- Quando credentials mudarem
- Quando passos de execucao mudarem

---

## 3. prod-credential-map.yaml — Mapeamento de Credentials

**Funcao**: Mapa de credential IDs entre DEV e PROD. Usado pelo Scan 2 do `*pre-deploy`.

### Estrutura

```yaml
swap_required:                    # Credentials que PRECISAM trocar
  - dev_id: "fGwpKYpERyVmR2tt"
    prod_id: "1ENA7UIm6ILehilJ"
    name: "Supabase account"

no_action:                        # Credentials que NAO precisam trocar (mesmo ID)
  - id: "amNI4dVfk3J8Bz0v"       # Redis
  - id: "LBPenwzFCkBeUYSp"       # WhatsApp OAuth

prod_credentials:                 # Lista de credentials conhecidas em PROD
  - id: "1ENA7UIm6ILehilJ"
  - id: "LBPenwzFCkBeUYSp"
  - id: "amNI4dVfk3J8Bz0v"
```

### Quando atualizar
- Quando criar nova credential em DEV ou PROD
- Quando ID de credential mudar
- Quando adicionar novo servico que precisa de credential

---

## 4. workflow-id-map.yaml — Mapeamento de Workflow IDs

**Funcao**: Mapa de nomes de workflow para IDs em DEV e PROD. Usado pelo `*pre-deploy` para gerar checklist com IDs corretos.

**Versao**: 2.0.0 (verificada ao vivo 2026-03-23)

### Estrutura

```yaml
update:                           # Workflows que devem ser deployados
  - name: "Main - Total Assistente"
    dev_id: "hLwhn94JSHonwHzl"
    prod_id: "9WDlyel5xRCLAvtH"
    prod_nodes: 75
    json_file: "Main - Total Assistente (4).json"
    critical: true
    has_whatsapp_trigger: true

  - name_dev: "Fix Conflito v2 - ..."   # Nome DIFERENTE em DEV e PROD
    name_prod: "Fix Conflito v2 - ..."
    dev_id: "ImW2P52iyCS0bGbQ"
    prod_id: "tyJ3YAAtSg1UurFj"
    prod_nodes: 185
    json_file: "User Premium - Total (3).json"  # JSON file tem OUTRO nome

skip:                             # Workflows que NAO devem ser tocados
  - name: "Service Message - 24 Hours"
    prod_id: "GNdoIS2zxGBa4CW0"
  - name: "My workflow"
    prod_id: "uzbB6BQ3gf0s3tTqEKGsX"
    active: false
```

### Discrepancias conhecidas entre nomes

| Situacao | Detalhe |
|----------|---------|
| "Fix Conflito v2" vs "User Premium" | Mesmo workflow, nomes diferentes. JSON file usa "User Premium". |
| "Report Unificado" vs "Relatorios Mensais-Semanais" | Mesmo workflow, nomes diferentes. JSON file usa "Relatorios". |
| "User Standard" | Nao existe como workflow separado no DEV. Deployar via JSON file. |

### Quando atualizar
- Quando criar novo workflow em DEV ou PROD
- Quando renomear workflow
- Quando IDs mudarem (reimport)
- Quando node count mudar significativamente (indicador de mudanca)

---

## 5. snapshot-registry.yaml — Registro de Snapshots

**Funcao**: Registro append-only de todos os snapshots capturados pelo `*snapshot`. Permite listar versoes e localizar snapshots antigos.

### Estrutura

```yaml
version: 1.0.0
snapshots:
  - date: "2026-03-23 14:30 UTC"
    label: "pre-v3.1"
    path: "data/snapshots/2026-03-23_14-30_pre-v3.1/"
    workflow_count: 6
    workflows: [lista de nomes]
    hashes: { workflow_slug: md5_hash }

  - date: "2026-03-23 16:00 UTC"
    label: "pos-v3.1"
    path: "data/snapshots/2026-03-23_16-00_pos-v3.1/"
    workflow_count: 6
    workflows: [lista de nomes]
    hashes: { workflow_slug: md5_hash }
```

### Regras
- **Append-only**: Nunca remover entradas
- **Automatico**: Gerenciado pelo `*snapshot`, nao editar manualmente
- **Hashes**: Usados pelo `*diff` para identificar workflows modificados (hash diferente = modificado)

### Quando limpar
- Se o arquivo ficar muito grande (>100 snapshots), mover antigos para arquivo morto
- Nunca deletar — pode ser necessario para auditoria

---

## Diagrama de Dependencias entre Data Files

```
environments.yaml (FONTE DA VERDADE)
    |
    |-- Consultado por: todos os tasks
    |-- Define: IPs, URLs, workflows, containers
    |
deploy-rules.yaml
    |
    |-- Consultado por: generate-deploy-checklist.md
    |-- Define: URL patterns, credential swaps, WhatsApp rules
    |-- Fonte: DEPLOY_N8N_WORKFLOWS.md
    |
prod-credential-map.yaml
    |
    |-- Consultado por: generate-deploy-checklist.md (Scan 2)
    |-- Define: credential DEV -> PROD mapping
    |
workflow-id-map.yaml
    |
    |-- Consultado por: generate-deploy-checklist.md, validate-post-deploy.md
    |-- Define: workflow name -> PROD ID, flags (critical, skip)
    |
snapshot-registry.yaml
    |
    |-- Consultado por: diff-versions.md, snapshot-dev.md
    |-- Gerenciado por: snapshot-dev.md (append-only)
    |-- Define: historico de snapshots com hashes
```
