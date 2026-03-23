# Checklist: Regras de Deploy N8N (DEV -> PROD)

Referencia: /home/totalAssistente/DEPLOY_N8N_WORKFLOWS.md

## Regras Estaticas (sempre se aplicam)

### URLs DEV -> PROD (23 ocorrencias conhecidas)
- [ ] Substituir `http://n8n-fcwk0sw4soscgsgs08g8gssk.76.13.172.17.sslip.io` -> `https://totalassistente.com.br`
- [ ] Substituir `http://n8n-zcgwwscwc8coos88c0g08sks.76.13.172.17.sslip.io` -> `https://totalassistente.com.br`
- [ ] Verificar que NAO resta nenhuma ocorrencia de `76.13.172.17` nos JSONs
- [ ] Verificar que NAO resta nenhuma ocorrencia de `sslip.io` nos JSONs

### Credential ID Supabase (8 nodes)
- [ ] Substituir `fGwpKYpERyVmR2tt` -> `1ENA7UIm6ILehilJ` em Main (7 nodes "Create a row")
- [ ] Substituir `fGwpKYpERyVmR2tt` -> `1ENA7UIm6ILehilJ` em User Premium (1 node)

### WhatsApp Trigger — Main Workflow (CRITICO)
- [ ] REMOVER node `trigger-whatsappsdadsa` (webhook fake)
- [ ] REMOVER node `Normalize WhatsApp payload` (code node)
- [ ] REMOVER node `trigger-whatsapp` do tipo code (transformador fake)
- [ ] ADICIONAR trigger real: `n8n-nodes-base.whatsAppTrigger`
- [ ] Credential do trigger: `WhatsApp OAuth account` (ID: `LBPenwzFCkBeUYSp`)
- [ ] Conexao: trigger-whatsapp -> Edit Fields (mesmo destino)

### Workflows a NAO Tocar
- [ ] Service Message - 24 Hours (PROD ID: GNdoIS2zxGBa4CW0) — NAO TOCAR

### Limpeza
- [ ] Limpar `pinData` de todos os JSONs (dados de teste)
- [ ] Limpar `staticData` se presente (dados de sessao)

### Credential Cosmetica (SEM acao)
- [x] `amNI4dVfk3J8Bz0v` — "Upstash 1" no dev, "Redis Germany" na prod — ID e o mesmo, nome e cosmetico

## Mapeamento Workflow -> PROD ID

| Workflow | PROD ID | Acao |
|----------|---------|------|
| Main - Total Assistente | 9WDlyel5xRCLAvtH | UPDATE |
| Calendar WebHooks - Total Assistente | ZZbMdcuCKx0fM712 | UPDATE |
| Financeiro - Total | eYWjnmvP8LQxY87g | UPDATE |
| Lembretes Total Assistente | sjDpjKqtwLk7ycki | UPDATE |
| Relatorios Mensais-Semanais | S2QgrsN6uteyB04E | UPDATE |
| User Premium - Total | tyJ3YAAtSg1UurFj | UPDATE |
| User Standard - Total | c8gtSmh1BPzZXbJa | UPDATE |
| Service Message - 24 Hours | GNdoIS2zxGBa4CW0 | NAO TOCAR |

## Passos de Execucao do Deploy

1. [ ] Pull do GitHub: `cd /home/totalAssistente && git pull origin main`
2. [ ] Copiar JSONs: `cp -r jsons/ /tmp/deploy_n8n/`
3. [ ] Aplicar correcoes nos JSONs (URLs, credentials, WhatsApp trigger, pinData)
4. [ ] Desativar workflows em PROD: `PUT /workflows/{id}` com `{ "active": false }`
5. [ ] Importar JSONs corrigidos: `PUT /workflows/{id}` com JSON completo
6. [ ] Reativar workflows: `PUT /workflows/{id}` com `{ "active": true }`
7. [ ] Verificar logs: `docker logs totalassistente-n8n --tail 50`
8. [ ] Executar `*validate-prod` para verificacao automatica

## Rollback
Se algo der errado: **"RESTAURAR GOLDEN BACKUP"**
- Backup: GOLDEN_BACKUP_20260213 (950MB)
- Restaura banco + dados N8N + workflows originais
