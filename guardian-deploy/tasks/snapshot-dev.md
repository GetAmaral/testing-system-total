---
task: Snapshot DEV Workflows
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - label: string (required) - Label descritivo para o snapshot (ex: "pre-v3.1", "pos-fix-calendario")
  - workflow_name: string (optional) - Nome do workflow especifico (default: todos)
Saida: |
  - snapshot_dir: data/snapshots/{YYYY-MM-DD}_{HH-MM}_{label}/ contendo JSONs
  - manifest: data/snapshots/{YYYY-MM-DD}_{HH-MM}_{label}/manifest.md
  - registry_entry: linha adicionada em data/snapshot-registry.yaml
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Verificar que N8N DEV esta acessivel (GET /api/v1/workflows)"
  - "[ ] Exportar workflows via API GET"
  - "[ ] Limpar pinData de cada JSON antes de salvar"
  - "[ ] Gerar hash MD5 de cada JSON normalizado"
  - "[ ] Criar manifest com metadados"
  - "[ ] Registrar snapshot no snapshot-registry.yaml"
---

# *snapshot

Captura snapshot versionado de todos os workflows do N8N DEV como JSON, gerando um registro imutavel para comparacao futura.

## Uso

```
@guardian

*snapshot pre-v3.1
# -> Snapshot de todos os workflows com label "pre-v3.1"

*snapshot pos-fix-calendario
# -> Snapshot apos correcao do calendario

*snapshot pre-deploy --workflow "Main - Total Assistente"
# -> Snapshot apenas do Main workflow
```

## READ-ONLY GATE (OBRIGATORIO)

- SOMENTE GET na API do N8N DEV: `http://76.13.172.17:5678/api/v1/workflows`
- NUNCA PUT/POST/DELETE
- NUNCA acessar producao
- Output SOMENTE em `squads/guardian-deploy/data/snapshots/`

## Elicitacao

```
? Label para este snapshot? (ex: "pre-v3.1", "pos-mudanca-financeiro")
  > [texto livre, obrigatorio]

? Quais workflows capturar?
  1. Todos (recomendado)
  2. Selecionar especificos
  > [selecao]

? [Se opcao 2] Quais workflows?
  1. Main - Total Assistente
  2. Calendar WebHooks - Total Assistente
  3. Financeiro - Total
  4. User Premium - Total
  5. User Standard - Total
  6. Lembretes Total Assistente
  7. Relatorios Mensais-Semanais
  > [multipla selecao]
```

## Fluxo de Execucao

```
1. PREPARACAO
   ├── Verificar guardrails-checklist
   ├── Verificar que N8N DEV responde (GET /api/v1/workflows)
   ├── Criar diretorio: data/snapshots/{YYYY-MM-DD}_{HH-MM}_{label}/
   └── Registrar timestamp UTC

2. EXPORTACAO
   ├── GET /api/v1/workflows -> lista de workflows
   ├── Para cada workflow (ou filtrado por nome):
   │   ├── GET /api/v1/workflows/{id} -> JSON completo
   │   ├── Limpar campo "pinData" (dados de teste do dev)
   │   ├── Limpar campo "staticData" se existir
   │   ├── Normalizar JSON (sort keys, indent 2)
   │   ├── Calcular hash MD5 do JSON normalizado
   │   └── Salvar como {workflow_name_slug}.json
   └── Contar workflows exportados

3. MANIFEST
   ├── Gerar manifest.md com template snapshot-manifest-tmpl.md:
   │   ├── Data e hora UTC
   │   ├── Label do snapshot
   │   ├── Para cada workflow:
   │   │   ├── Nome e ID
   │   │   ├── Numero de nodes
   │   │   ├── Numero de connections
   │   │   ├── Hash MD5
   │   │   └── Tamanho do arquivo
   │   └── Total de workflows
   └── Salvar no diretorio do snapshot

4. REGISTRO
   ├── Adicionar entrada no data/snapshot-registry.yaml:
   │   ├── date: "YYYY-MM-DD HH:MM UTC"
   │   ├── label: "{label}"
   │   ├── path: "data/snapshots/{dir_name}/"
   │   ├── workflow_count: N
   │   ├── workflows: [lista de nomes]
   │   └── hashes: {workflow: hash}
   └── Confirmar registro ao usuario

5. RESULTADO
   ├── Apresentar resumo:
   │   ├── "Snapshot '{label}' capturado com sucesso"
   │   ├── N workflows salvos
   │   ├── Path do snapshot
   │   └── "Use *diff {label_anterior} {label} para comparar"
   └── HALT — aguardar proximo comando
```

## Metadata

```yaml
version: 1.0.0
dependencies:
  - N8N dev API (GET only)
  - data/snapshot-registry.yaml
  - templates/snapshot-manifest-tmpl.md
tags:
  - snapshot
  - versioning
  - diff-check
```
