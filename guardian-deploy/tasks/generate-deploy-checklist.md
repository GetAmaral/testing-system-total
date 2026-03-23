---
task: Generate Granular Deploy Checklist
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: false
Entrada: |
  - dev_jsons: JSONs do DEV (snapshot mais recente ou via API GET)
  - prod_jsons: JSONs de PROD em /home/totalAssistente/jsonsProd/
  - deploy_doc: /home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md
  - deploy_rules: data/deploy-rules.yaml
Saida: |
  - checklist: .md em output/deploys/{date}-deploy-checklist.md com checkboxes
  - correction_count: numero total de correcoes necessarias
  - risk_summary: classificacao de risco por workflow
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Carregar JSONs de DEV (snapshot ou API)"
  - "[ ] Carregar JSONs de PROD (/home/totalAssistente/jsonsProd/)"
  - "[ ] Carregar regras de deploy (deploy-rules.yaml + DEPLOY_N8N_WORKFLOWS.md)"
  - "[ ] SCAN 1: URLs de dev em cada node"
  - "[ ] SCAN 2: Credential IDs inexistentes em prod"
  - "[ ] SCAN 3: Nodes fake do WhatsApp trigger"
  - "[ ] SCAN 4: pinData com dados de teste"
  - "[ ] SCAN 5: Workflows a incluir/excluir do deploy"
  - "[ ] Gerar checklist GRANULAR nivel-node com checkboxes"
  - "[ ] Contar total de correcoes"
  - "[ ] Salvar em output/deploys/"
---

# *pre-deploy

Gera checklist GRANULAR de deploy (nivel-node) escaneando CADA JSON do DEV para encontrar TODAS as correcoes necessarias antes de enviar para PROD. Esta e a task mais importante do squad — resolve a maior dor do deploy manual: ESQUECER correcoes.

## Uso

```
@guardian

*pre-deploy
# -> Scan completo: compara DEV vs PROD, gera checklist com TUDO

*checklist
# -> Versao rapida: apenas scan de correcoes sem diff completo

*checklist --workflow "Main - Total Assistente"
# -> Checklist apenas para um workflow especifico
```

## READ-ONLY GATE (OBRIGATORIO)

- SOMENTE leitura: JSONs locais do DEV (snapshot) e PROD (/home/totalAssistente/jsonsProd/)
- NUNCA modificar nenhum JSON
- NUNCA executar deploy
- Output SOMENTE em `squads/guardian-deploy/output/deploys/`

## Fluxo de Execucao

```
1. CARREGAR FONTES
   ├── DEV: Carregar JSONs do snapshot mais recente (data/snapshots/)
   │   └── Se nao existe snapshot: fazer GET /api/v1/workflows no DEV
   ├── PROD: Carregar JSONs de /home/totalAssistente/jsonsProd/
   ├── REGRAS: Carregar data/deploy-rules.yaml
   ├── DOC: Carregar /home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md
   └── MAP: Carregar data/workflow-id-map.yaml e data/prod-credential-map.yaml

2. INVENTARIO DE WORKFLOWS
   ├── Listar workflows DEV e PROD
   ├── Para cada workflow:
   │   ├── ATUALIZAR: presente em ambos (gerar correcoes)
   │   ├── NOVO: presente so em DEV (avaliar se deve deployar)
   │   ├── AUSENTE: presente so em PROD (NAO TOCAR — ex: Service Message)
   │   └── INALTERADO: hash identico (pular)
   └── Gerar tabela de mapeamento: workflow -> PROD ID -> acao

3. SCAN 1 — URLS DE DEV (para cada workflow a deployar)
   ├── Serializar JSON como string
   ├── Buscar TODOS os padroes de URL de dev:
   │   ├── "76.13.172.17" (IP do dev)
   │   ├── "sslip.io" (dominio dev)
   │   ├── "n8n-fcwk0sw4soscgsgs08g8gssk" (subdominio dev 1)
   │   ├── "n8n-zcgwwscwc8coos88c0g08sks" (subdominio dev 2)
   │   └── Qualquer URL que nao seja "totalassistente.com.br"
   ├── Para cada ocorrencia encontrada:
   │   ├── Identificar: QUAL node (name e type)
   │   ├── Identificar: QUAL campo (url, value, expression)
   │   ├── Registrar: valor atual (DE)
   │   └── Registrar: valor correto (PARA): "https://totalassistente.com.br"
   └── Contar total de URLs a corrigir

4. SCAN 2 — CREDENTIAL IDS (para cada workflow a deployar)
   ├── Extrair todos os credential IDs referenciados nos nodes
   ├── Cruzar com data/prod-credential-map.yaml
   ├── Para cada credential ID que NAO existe em PROD:
   │   ├── Identificar: QUAL node (name e type)
   │   ├── Registrar: credential ID atual (DE)
   │   ├── Registrar: credential ID correto em PROD (PARA)
   │   └── Registrar: nome da credential para referencia
   └── Contar total de credentials a corrigir

5. SCAN 3 — WHATSAPP TRIGGER FAKE (apenas workflow Main)
   ├── No workflow "Main - Total Assistente":
   │   ├── Buscar nodes com nomes:
   │   │   ├── "trigger-whatsappsdadsa" (webhook fake)
   │   │   ├── "Normalize WhatsApp payload" (code node)
   │   │   └── "trigger-whatsapp" do tipo code (NÃO o real trigger)
   │   ├── Se encontrou: gerar item de checklist para REMOVER cada um
   │   ├── Gerar item para ADICIONAR trigger real:
   │   │   ├── Type: n8n-nodes-base.whatsAppTrigger
   │   │   ├── Name: trigger-whatsapp
   │   │   ├── Credential: WhatsApp OAuth account (ID: LBPenwzFCkBeUYSp)
   │   │   └── Conexao: trigger-whatsapp -> Edit Fields
   │   └── Se NAO encontrou nodes fake: pular (ja esta correto)
   └── Este e o item mais CRITICO do checklist

6. SCAN 4 — PINDATA (para cada workflow a deployar)
   ├── Verificar campo "pinData" em cada JSON
   ├── Se pinData nao e null/vazio:
   │   ├── Listar quais nodes tem dados pinnados
   │   ├── Gerar item de checklist para limpar pinData
   │   └── ALERTA: pinData sao dados de teste que NAO devem ir para prod
   └── Contar workflows com pinData

7. SCAN 5 — VERIFICACOES ADICIONAIS
   ├── Nodes com "executeOnce: false" que deveriam ser true
   ├── Nodes com "continueOnFail: true" que podem mascarar erros
   ├── HTTP Request nodes com timeout < 10000ms
   ├── AI Agent nodes: verificar se model/temperature sao os desejados para PROD
   └── Webhook nodes: verificar se path esta correto para PROD

8. GERAR CHECKLIST
   ├── Usar template deploy-checklist-tmpl.md
   ├── Organizar por WORKFLOW:
   │   ├── Para cada workflow:
   │   │   ├── ID de PROD e acao (UPDATE/NAO TOCAR)
   │   │   ├── SECAO: URLs a corrigir
   │   │   │   └── [ ] Node "{name}" ({type}): campo {field}
   │   │   │       DE: {url_dev}
   │   │   │       PARA: {url_prod}
   │   │   ├── SECAO: Credentials a trocar
   │   │   │   └── [ ] Node "{name}" ({type}): credential
   │   │   │       DE: {cred_dev} ({cred_name})
   │   │   │       PARA: {cred_prod} ({cred_name})
   │   │   ├── SECAO: Nodes a remover/adicionar (WhatsApp trigger)
   │   │   │   └── [ ] REMOVER node "{name}" ({type})
   │   │   │   └── [ ] ADICIONAR trigger real (detalhes)
   │   │   ├── SECAO: pinData a limpar
   │   │   │   └── [ ] Limpar pinData (nodes: {lista})
   │   │   └── SECAO: Verificacoes adicionais
   │   │       └── [ ] {verificacao}
   │   └── (repetir para cada workflow)
   │
   ├── SECAO FINAL: Passos de execucao
   │   ├── [ ] 1. Pull do GitHub: cd /home/totalAssistente && git pull origin main
   │   ├── [ ] 2. Copiar JSONs: cp -r jsons/ /tmp/deploy_n8n/
   │   ├── [ ] 3. Aplicar TODAS as correcoes acima nos JSONs
   │   ├── [ ] 4. Desativar workflows em PROD (PUT /workflows/{id} active:false)
   │   ├── [ ] 5. Importar JSONs corrigidos (PUT /workflows/{id} com JSON)
   │   ├── [ ] 6. Reativar workflows (PUT /workflows/{id} active:true)
   │   ├── [ ] 7. Verificar logs: docker logs totalassistente-n8n --tail 50
   │   └── [ ] 8. Executar *validate-prod para verificacao automatica
   │
   ├── SECAO: Rollback
   │   └── Se algo der errado: dizer "RESTAURAR GOLDEN BACKUP"
   │
   └── CONTAGEM FINAL
       ├── Total de correcoes: {N} itens
       ├── URLs: {n_urls} | Credentials: {n_creds} | Nodes: {n_nodes} | pinData: {n_pin}
       ├── Workflows a atualizar: {n_workflows}
       ├── Workflows a pular: {n_skip}
       └── ALERTA: "Confira que marcou TODOS os {N} itens antes de deployar!"

9. SALVAR E APRESENTAR
   ├── Salvar em output/deploys/{date}-deploy-checklist.md
   ├── Apresentar resumo ao usuario:
   │   ├── Total de correcoes encontradas
   │   ├── Itens criticos (WhatsApp trigger, credentials)
   │   ├── Path do checklist
   │   └── "Siga o checklist item por item. Apos deploy, use *validate-prod"
   └── HALT — aguardar proximo comando
```

## Padroes de Scan Conhecidos

### URLs de DEV que precisam virar PROD

| Padrao DEV | Substituir por |
|------------|----------------|
| `http://n8n-fcwk0sw4soscgsgs08g8gssk.76.13.172.17.sslip.io` | `https://totalassistente.com.br` |
| `http://n8n-zcgwwscwc8coos88c0g08sks.76.13.172.17.sslip.io` | `https://totalassistente.com.br` |
| `http://76.13.172.17:5678` | `https://totalassistente.com.br` |

### Credentials DEV que precisam virar PROD

| Credential DEV | Credential PROD | Nome |
|----------------|-----------------|------|
| `fGwpKYpERyVmR2tt` | `1ENA7UIm6ILehilJ` | Supabase account |

### Credential cosmética (SEM ação)

| ID | Nome DEV | Nome PROD | Ação |
|----|----------|-----------|------|
| `amNI4dVfk3J8Bz0v` | Upstash 1 | Redis Germany | Nenhuma (ID é o mesmo) |

### Workflows que NÃO devem ser tocados

| Workflow | PROD ID | Razão |
|----------|---------|-------|
| Service Message - 24 Hours | GNdoIS2zxGBa4CW0 | Não está nos exports novos |

## Metadata

```yaml
version: 1.0.0
dependencies:
  - JSONs de DEV (snapshot ou API)
  - JSONs de PROD (/home/totalAssistente/jsonsProd/)
  - /home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md
  - data/deploy-rules.yaml
  - data/prod-credential-map.yaml
  - data/workflow-id-map.yaml
  - templates/deploy-checklist-tmpl.md
tags:
  - deploy
  - checklist
  - granular
  - node-level
  - pre-deploy
  - critical
```
