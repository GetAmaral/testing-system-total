# Guardian Deploy Squad

Squad copiloto de deploy do Total Assistente. Gerencia o ciclo de vida completo de deploy: snapshots versionados, testes de features, checklist GRANULAR (nivel-node) e validacao pos-deploy.

## O que faz

Resolve a **maior dor do deploy manual**: esquecer de trocar URLs, credentials, nodes e pinData ao mover workflows do DEV para PROD.

- **DIFF-CHECK**: Captura snapshots do DEV e compara versoes para ver o que mudou
- **SPEC-AUDITOR**: Testa novas features contra criterios de qualidade
- **PRE-DEPLOY**: Gera checklist GRANULAR (nivel-node) com cada correcao necessaria
- **POS-DEPLOY**: Valida PROD para confirmar que nada ficou de DEV

## Agente

| Agente | Persona | Papel |
|--------|---------|-------|
| **Vigil** | Guardian | Copiloto de deploy — orquestra tudo, nunca executa deploy |

## Como usar

### 1. Ativar o Squad
```
@guardian
```

### 2. Antes de fazer mudancas no DEV
```
*snapshot pre-v3.1
```

### 3. Depois de fazer mudancas
```
*snapshot pos-v3.1
*diff --latest
```

### 4. Testar novas features
```
*spec "Adicionei filtro de categoria"
*audit-spec --auto
```

### 5. Gerar checklist de deploy (SUPER-PODER)
```
*pre-deploy
```

### 6. Apos deploy manual
```
*validate-prod
```

### 7. Ciclo completo
```
*lifecycle
```

## Guardrails

- **READ-ONLY**: Nunca modifica workflows em DEV ou PROD
- **NUNCA EXECUTA DEPLOY**: Apenas gera checklists para o humano
- **PROD via delegacao**: Acesso a producao somente via @analisador (SSH read-only)
- Output apenas em `output/` e `data/snapshots/`

## Dependencias

| Squad | Uso |
|-------|-----|
| testador-n8n | Testes funcionais no DEV |
| deploy-review | Diff DEV vs PROD |
| auditor-360 | Teste feature-level |
| analisador-n8n | Leitura read-only de PROD |

## Outputs

Todos os relatorios em `squads/guardian-deploy/output/`:
- `output/diffs/` — Relatorios de diff entre versoes
- `output/specs/` — Especificacoes de mudanca
- `output/audits/` — Relatorios de auditoria de spec
- `output/deploys/` — Checklists de deploy e validacoes pos-deploy
