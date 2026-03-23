# Referencia de Tasks e Workflows

## Tasks

### 1. snapshot-dev (`*snapshot`)

**Proposito**: Capturar estado atual dos workflows DEV como JSONs versionados.

| Campo | Valor |
|-------|-------|
| Elicit | true (pergunta label e escopo) |
| Input | N8N DEV API GET /api/v1/workflows |
| Output | `data/snapshots/{YYYY-MM-DD}_{HH-MM}_{label}/` |
| Registry | Append em `data/snapshot-registry.yaml` |
| Fallback | Se API indisponivel, usa JSONs locais em `/home/AIOS-Total/totalAssistente/jsons/` |

**Processamento por workflow**:
1. GET JSON completo via API
2. Remover campo `pinData` (dados de teste)
3. Remover campo `staticData` (dados de sessao)
4. Normalizar JSON (sort keys, indent 2)
5. Calcular hash MD5 do JSON normalizado
6. Salvar como `{workflow_name_slug}.json`

**Manifest gerado**: Para cada workflow lista nome, ID, node count, connection count, hash MD5, tamanho.

---

### 2. diff-versions (`*diff`)

**Proposito**: Comparar dois snapshots DEV para identificar mudancas.

| Campo | Valor |
|-------|-------|
| Elicit | true (pergunta v1 e v2, ou usa --latest) |
| Input | Dois diretorios de snapshot com JSONs |
| Output | `output/diffs/{date}-diff-{v1}-vs-{v2}.md` |

**Niveis de comparacao**:

| Nivel | O que compara | Campos |
|-------|---------------|--------|
| Nodes | Adicionados, removidos, modificados | parameters, credentials, typeVersion, retry, timeout |
| Connections | Caminhos novos, removidos, reorganizados | source, target, sourceHandle |
| AI Prompts | System messages, model, temperature | Diff lado-a-lado completo |
| URLs | Webhook URLs, HTTP request URLs | url, value, expression |
| Settings | Timezone, error workflow, saveExecution | settings.* |
| Credentials | IDs e nomes de credentials | credentials.* |

**Classificacao de mudancas**:

| Tipo | Risco | Exemplos |
|------|-------|----------|
| STRUCTURAL | HIGH | Nodes adicionados/removidos, conexoes mudadas |
| CONFIG | MEDIUM | Parametros, settings, timeouts |
| PROMPT | CRITICAL | System messages AI, model, temperature |
| COSMETIC | LOW | Posicao de nodes, notas, descricoes |

---

### 3. create-spec (`*spec`)

**Proposito**: Documentar O QUE mudou e POR QUE, com criterios de aceite testaveis.

| Campo | Valor |
|-------|-------|
| Elicit | true (pergunta descricao, motivacao, workflows) |
| Input | Descricao do usuario + diff report (opcional) |
| Output | `output/specs/{date}-spec-{slug}.md` |

**Mapeamento de features**: Cruza workflows afetados com as 28 features do auditor-360:

| Workflow | Features Mapeadas |
|----------|-------------------|
| Financeiro - Total | financeiro/01 a 04 |
| Calendar WebHooks | agenda/01 a 08 |
| Main - Total Assistente | bot-whatsapp/01 a 06 |
| Fix Conflito v2 / User Premium | bot-whatsapp/02 + features premium |
| User Standard | bot-whatsapp/03 + features standard |

---

### 4. audit-spec (`*audit-spec`)

**Proposito**: Testar features contra a spec. Veredicto GO/NO-GO/CONDICIONAL.

| Campo | Valor |
|-------|-------|
| Elicit | true (pergunta spec, nivel de teste, regressao) |
| Input | Spec .md |
| Output | `output/audits/{date}-spec-audit-{slug}.md` |
| Delegacao | @testador (*simulate, *validate), @auditor-360 (metodologia) |

**5 dimensoes de avaliacao**:

| Dimensao | Pergunta | Score |
|----------|----------|-------|
| Funciona? | Criterios de aceite passaram? | 0-10 |
| E util? | Resolve o problema descrito na spec? | 0-10 |
| E escalavel? | Cria bottlenecks, loops, N+1? | 0-10 |
| Performance? | Node count cresceu muito? Tempo de resposta? | 0-10 |
| Seguro? | Credentials expostas? Webhook sem auth? | 0-10 |

**Veredictos**:
- **GO**: Todos criterios PASS, scores >= 7
- **CONDICIONAL**: Alguns PARTIAL, sem FAILs criticos, scores >= 5
- **NO-GO**: FAILs criticos, regressoes, scores < 5

---

### 5. generate-deploy-checklist (`*pre-deploy`) — TASK MAIS IMPORTANTE

**Proposito**: Escanear JSONs DEV e gerar checklist GRANULAR (nivel-node) com TODAS as correcoes.

| Campo | Valor |
|-------|-------|
| Elicit | false (automatico) |
| Input | JSONs DEV + JSONs PROD + deploy-rules.yaml + DEPLOY_N8N_WORKFLOWS.md |
| Output | `output/deploys/{date}-deploy-checklist.md` |

**5 Scans executados**:

#### Scan 1 — URLs de DEV
- Serializa cada JSON como string
- Busca patterns: `76.13.172.17`, `sslip.io`, `n8n-fcwk0sw4soscgsgs08g8gssk`, `n8n-zcgwwscwc8coos88c0g08sks`
- Para cada ocorrencia: identifica node name, node type, campo, valor DE, valor PARA

#### Scan 2 — Credential IDs
- Extrai todos credential IDs de cada node
- Cruza com `prod-credential-map.yaml`
- Para cada mismatch: identifica node name, node type, ID DE, ID PARA, nome da credential

#### Scan 3 — WhatsApp Trigger Fake (somente Main workflow)
- Busca nodes: `trigger-whatsappsdadsa`, `Normalize WhatsApp payload`, `trigger-whatsapp` (type: code)
- Se encontrou: gerar itens para REMOVER + ADICIONAR trigger real
- Trigger real: `n8n-nodes-base.whatsAppTrigger`, credential `LBPenwzFCkBeUYSp`

#### Scan 4 — pinData
- Verifica campo `pinData` em cada JSON
- Se nao-null: listar quais nodes tem dados pinnados

#### Scan 5 — Verificacoes Adicionais
- `executeOnce` settings
- `continueOnFail` que pode mascarar erros
- HTTP Request nodes com timeout baixo
- AI Agent nodes: model/temperature para PROD

**Formato do checklist**: Agrupado por workflow, com `[ ]` checkboxes. Cada item tem: node name, node type, campo, valor DE -> valor PARA. Contagem final com totais por tipo.

---

### 6. validate-post-deploy (`*validate-prod`)

**Proposito**: Verificar PROD apos deploy. Buscar restos de DEV.

| Campo | Valor |
|-------|-------|
| Elicit | true (pergunta quais workflows e tempo desde deploy) |
| Input | Export workflows de PROD via @analisador |
| Output | `output/deploys/{date}-post-deploy-validation.md` |
| Delegacao | @analisador (docker ps, docker logs, n8n export:workflow --all) |

**7 verificacoes**:

| # | Verificacao | Esperado | Se falhar |
|---|------------|----------|-----------|
| 1 | docker ps | 8 containers UP | CRITICAL_FAILURE |
| 2 | docker logs (erros) | 0 criticos | CRITICAL/ISSUES |
| 3 | URLs de DEV nos exports | 0 encontradas | CRITICAL_FAILURE |
| 4 | Credentials de DEV | 0 encontradas | CRITICAL_FAILURE |
| 5 | WhatsApp trigger real | whatsAppTrigger presente | CRITICAL_FAILURE |
| 6 | pinData | 0 workflows | ISSUES_FOUND |
| 7 | Workflows ativos | 8/8 | CRITICAL_FAILURE |

**Veredictos**:
- **ALL_CLEAR**: Tudo OK. Deploy bem-sucedido.
- **ISSUES_FOUND**: Problemas menores (pinData residual, warnings nos logs). Monitorar.
- **CRITICAL_FAILURE**: Problema grave. Rollback imediato: "RESTAURAR GOLDEN BACKUP".

---

## Workflows

### full-lifecycle.yaml

```
Step 1: *snapshot pre-mudanca          [auto]
Step 2: PAUSA — usuario faz mudancas   [manual]
Step 3: *snapshot pos-mudanca          [auto]
Step 4: *diff --latest                 [auto]
Step 5: *spec --from-diff latest       [interativo]
Step 6: *audit-spec --auto             [auto + delegacao]
Step 7: *pre-deploy                    [auto]
Step 8: PAUSA — usuario faz deploy     [manual]
Step 9: *validate-prod                 [auto + delegacao]
```

### diff-check.yaml

```
Step 1: *snapshot {label}              [interativo]
Step 2: *diff --latest                 [auto]
```

### spec-audit.yaml

```
Step 1: *spec                          [interativo]
Step 2: *audit-spec --auto             [auto + delegacao]
```

### pre-deploy.yaml

```
Step 1: *pre-deploy                    [auto]
Step 2: PAUSA — usuario faz deploy     [manual]
Step 3: *validate-prod                 [auto + delegacao]
```
