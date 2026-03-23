---
task: Diff Between DEV Versions
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - snapshot_v1: string (required) - Label ou path do snapshot antigo
  - snapshot_v2: string (required) - Label ou path do snapshot novo
  - flag_latest: boolean (optional) - Se true, compara ultimo com penultimo automaticamente
Saida: |
  - diff_report: .md em output/diffs/{date}-diff-{v1}-vs-{v2}.md
  - changes_summary: lista de mudancas com classificacao
  - risk_level: LOW|MEDIUM|HIGH|CRITICAL
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Carregar manifests dos dois snapshots"
  - "[ ] Comparar workflows presentes em cada snapshot"
  - "[ ] Para cada workflow modificado, comparar JSON estruturalmente"
  - "[ ] Classificar cada mudanca por tipo e risco"
  - "[ ] Gerar relatorio de diff"
  - "[ ] Salvar em output/diffs/"
---

# *diff

Compara dois snapshots DEV para identificar exatamente o que mudou entre versoes dos workflows N8N.

## Uso

```
@guardian

*diff pre-v3.1 pos-v3.1
# -> Compara snapshots por label

*diff --latest
# -> Compara ultimo snapshot com penultimo automaticamente
```

## READ-ONLY GATE (OBRIGATORIO)

- SOMENTE leitura de arquivos locais (data/snapshots/)
- NUNCA acessar N8N API para diff (usar snapshots ja capturados)
- Output SOMENTE em `squads/guardian-deploy/output/diffs/`

## Elicitacao

```
? [Se nao usou --latest] Qual o snapshot ANTIGO (v1)?
  {lista numerada de snapshots do registry}
  > [selecao]

? Qual o snapshot NOVO (v2)?
  {lista numerada de snapshots do registry}
  > [selecao]
```

## Fluxo de Execucao

```
1. CARREGAR SNAPSHOTS
   ├── Ler data/snapshot-registry.yaml
   ├── Localizar v1 e v2 por label ou path
   ├── Se --latest: pegar os 2 mais recentes
   ├── Carregar manifest.md de cada snapshot
   └── Carregar JSONs de cada snapshot

2. INVENTARIO DE WORKFLOWS
   ├── Listar workflows presentes em v1 e v2
   ├── Identificar: ADICIONADOS (so em v2)
   ├── Identificar: REMOVIDOS (so em v1)
   ├── Identificar: MODIFICADOS (hash diferente)
   └── Identificar: INALTERADOS (hash identico)

3. PARA CADA WORKFLOW MODIFICADO — DIFF ESTRUTURAL
   ├── 3a. NODES
   │   ├── Nodes adicionados (presentes em v2 mas nao em v1)
   │   ├── Nodes removidos (presentes em v1 mas nao em v2)
   │   ├── Nodes modificados (mesmo name, parametros diferentes)
   │   └── Para cada node modificado:
   │       ├── Mudancas em parameters (valores, expressions)
   │       ├── Mudancas em credentials
   │       ├── Mudancas em retry/timeout settings
   │       └── Mudancas em typeVersion
   │
   ├── 3b. CONNECTIONS
   │   ├── Conexoes adicionadas (novos caminhos)
   │   ├── Conexoes removidas (caminhos cortados)
   │   └── Conexoes reorganizadas (fonte/destino mudaram)
   │
   ├── 3c. AI PROMPTS (DESTAQUE ESPECIAL)
   │   ├── System messages mudaram?
   │   ├── Model mudou? (ex: gpt-4.1-mini -> gpt-4.5)
   │   ├── Temperature mudou?
   │   ├── Tools/functions mudaram?
   │   └── DIFF LADO A LADO do prompt antigo vs novo
   │
   ├── 3d. URLS E WEBHOOKS
   │   ├── URLs de webhook mudaram?
   │   ├── URLs HTTP request mudaram?
   │   └── Metodos HTTP mudaram?
   │
   ├── 3e. SETTINGS
   │   ├── Timezone mudou?
   │   ├── Error workflow mudou?
   │   └── saveExecution settings mudaram?
   │
   └── 3f. CREDENTIALS
       ├── Credential IDs mudaram?
       ├── Credential names mudaram?
       └── Novos credentials referenciados?

4. CLASSIFICACAO DE MUDANCAS
   ├── STRUCTURAL: Nodes adicionados/removidos, conexoes mudadas
   ├── CONFIG: Parametros, settings, timeouts
   ├── PROMPT: System messages, model, temperature (AI)
   ├── COSMETIC: Posicao de nodes, notas, descricoes
   └── Para cada mudanca, atribuir risco:
       ├── LOW: Cosmetico, notas, posicao
       ├── MEDIUM: Parametros, configuracoes
       ├── HIGH: Nodes novos/removidos, conexoes, URLs
       └── CRITICAL: Prompts AI, logica de negocio, credentials

5. GERAR RELATORIO
   ├── Usar template diff-report-tmpl.md
   ├── Resumo executivo com metricas
   ├── Para cada workflow modificado: detalhes completos
   ├── Mudancas de prompt AI em destaque (diff lado-a-lado)
   ├── Risco geral: LOW|MEDIUM|HIGH|CRITICAL
   └── Salvar em output/diffs/{date}-diff-{v1}-vs-{v2}.md

6. APRESENTAR RESULTADO
   ├── Resumo conciso das mudancas
   ├── Risco geral
   ├── Sugestao de proximo passo:
   │   ├── Se mudou features: "Use *spec para documentar e *audit-spec para testar"
   │   └── Se pronto para deploy: "Use *pre-deploy para gerar checklist"
   └── HALT — aguardar proximo comando
```

## Metadata

```yaml
version: 1.0.0
dependencies:
  - data/snapshot-registry.yaml
  - data/snapshots/ (JSONs)
  - templates/diff-report-tmpl.md
tags:
  - diff
  - comparison
  - versioning
  - diff-check
```
