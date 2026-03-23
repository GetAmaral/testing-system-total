# Checklist: Guardian Guardrails

## Verificacao OBRIGATORIA antes de cada operacao

### Operacoes PERMITIDAS
- [x] Ler arquivos com Read tool
- [x] Buscar arquivos com Glob tool
- [x] Buscar conteudo com Grep tool
- [x] GET na API do N8N DEV (http://76.13.172.17:5678/api/v1/)
- [x] Ler JSONs de PROD em /home/totalAssistente/jsonsProd/ (leitura local)
- [x] Criar .md em `squads/guardian-deploy/output/`
- [x] Criar .json em `squads/guardian-deploy/data/snapshots/`
- [x] Atualizar `squads/guardian-deploy/data/snapshot-registry.yaml`
- [x] Delegar ao @analisador para SSH read-only em PROD
- [x] Delegar ao @testador para testes no DEV

### Operacoes BLOQUEADAS
- [ ] ~~PUT/POST/DELETE em N8N API (DEV ou PROD)~~
- [ ] ~~SSH direto para producao~~
- [ ] ~~Modificar workflows em qualquer ambiente~~
- [ ] ~~Executar deploy~~
- [ ] ~~Enviar mensagens WhatsApp~~
- [ ] ~~Escrever em Supabase~~
- [ ] ~~docker stop/restart/rm~~
- [ ] ~~git push/commit~~
- [ ] ~~npm install/uninstall~~
- [ ] ~~Edit/Write em arquivos fora de output/ e data/snapshots/~~

### Validacao de Path

Antes de escrever qualquer arquivo, verificar:
```
path DEVE comecar com: squads/guardian-deploy/output/
                    ou: squads/guardian-deploy/data/snapshots/
                    ou: squads/guardian-deploy/data/snapshot-registry.yaml
path NUNCA deve estar em: totalAssistente/, site/, jsons/, jsonsProd/
```

### Em caso de duvida
**NAO execute. Pergunte ao usuario.**
