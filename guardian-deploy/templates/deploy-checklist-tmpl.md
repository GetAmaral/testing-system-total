# Checklist de Deploy — DEV -> PROD

**Data**: {date}
**Gerado por**: Vigil (Guardian)
**Total de correcoes**: **{total_corrections} itens**

---

## Resumo de Correcoes

| Tipo | Quantidade |
|------|------------|
| URLs DEV -> PROD | {n_urls} |
| Credential IDs | {n_credentials} |
| Nodes a remover/adicionar | {n_nodes} |
| pinData a limpar | {n_pindata} |
| Verificacoes adicionais | {n_extra} |
| **TOTAL** | **{total_corrections}** |

## Workflows a Deployar

| Workflow | PROD ID | Acao | Correcoes |
|----------|---------|------|-----------|
| {name} | {prod_id} | UPDATE | {n_corrections} |
| Service Message - 24 Hours | GNdoIS2zxGBa4CW0 | NAO TOCAR | 0 |

---

## Correcoes por Workflow

### {workflow_name} (PROD ID: {prod_id})

#### URLs DEV -> PROD

| | Node | Tipo | Campo | DE | PARA |
|---|------|------|-------|-----|------|
| [ ] | {node_name} | {node_type} | {field} | `{url_dev}` | `{url_prod}` |

#### Credential IDs

| | Node | Tipo | DE | PARA | Nome |
|---|------|------|-----|------|------|
| [ ] | {node_name} | {node_type} | `{cred_dev}` | `{cred_prod}` | {cred_name} |

#### Nodes a Remover

| | Node | Tipo | Razao |
|---|------|------|-------|
| [ ] | {node_name} | {node_type} | {razao} |

#### Nodes a Adicionar

| | Node | Tipo | Credential | Conexao |
|---|------|------|-----------|---------|
| [ ] | {node_name} | {node_type} | {credential} | {conexao} |

#### pinData

| | Acao |
|---|------|
| [ ] | Limpar pinData (nodes afetados: {node_list}) |

#### Verificacoes Adicionais

| | Verificacao |
|---|-------------|
| [ ] | {verificacao} |

*(repetir para cada workflow)*

---

## Passos de Execucao

- [ ] **1.** Pull do GitHub: `cd /home/totalAssistente && git pull origin main`
- [ ] **2.** Copiar JSONs para area de trabalho: `cp -r jsons/ /tmp/deploy_n8n/`
- [ ] **3.** Aplicar TODAS as {total_corrections} correcoes acima nos JSONs
- [ ] **4.** Conferir: marquei TODOS os {total_corrections} itens acima? (contar!)
- [ ] **5.** Desativar workflows em PROD (um por um):
  - [ ] `PUT /workflows/9WDlyel5xRCLAvtH` active: false (Main)
  - [ ] `PUT /workflows/ZZbMdcuCKx0fM712` active: false (Calendar)
  - [ ] `PUT /workflows/eYWjnmvP8LQxY87g` active: false (Financeiro)
  - [ ] `PUT /workflows/sjDpjKqtwLk7ycki` active: false (Lembretes)
  - [ ] `PUT /workflows/S2QgrsN6uteyB04E` active: false (Relatorios)
  - [ ] `PUT /workflows/tyJ3YAAtSg1UurFj` active: false (User Premium)
  - [ ] `PUT /workflows/c8gtSmh1BPzZXbJa` active: false (User Standard)
- [ ] **6.** Importar JSONs corrigidos (PUT /workflows/{id} com JSON)
- [ ] **7.** Reativar workflows (mesmos IDs com active: true)
- [ ] **8.** Verificar logs: `docker logs totalassistente-n8n --tail 50`
- [ ] **9.** Executar `@guardian *validate-prod` para verificacao automatica

---

## Rollback

Se algo der errado: **"RESTAURAR GOLDEN BACKUP"**
- Backup: GOLDEN_BACKUP_20260213
- Restaura banco + N8N + workflows originais

---

## Conferencia Final

```
TOTAL DE CORRECOES: {total_corrections}
ITENS MARCADOS:    ___ / {total_corrections}

Se o numero acima nao bate: VOCE ESQUECEU ALGO. Revisar o checklist.
```

---

*Gerado pelo Guardian Deploy Squad - Vigil*
*ALERTA: Confira que marcou TODOS os {total_corrections} itens antes de deployar!*
