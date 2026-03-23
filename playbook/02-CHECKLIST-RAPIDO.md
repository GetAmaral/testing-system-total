# Checklist Rapido — Cole do Lado do Monitor

```
╔═══════════════════════════════════════════════════╗
║        ESTEIRA DE PRODUCAO — TOTAL ASSISTENTE      ║
║        Siga SEMPRE. Sem atalhos. Sem pular.        ║
╚═══════════════════════════════════════════════════╝

@guardian

── ANTES DE MEXER ──────────────────────────────────

[ ] *snapshot pre-{nome}        (foto ANTES)

── FAZENDO MUDANCA ─────────────────────────────────

[ ] Mudancas feitas no N8N DEV
[ ] Testei no editor do N8N DEV

── DEPOIS DE MEXER ─────────────────────────────────

[ ] *snapshot pos-{nome}        (foto DEPOIS)
[ ] *diff --latest              (o que mudou?)
[ ] Mudancas conferidas — sao as que eu esperava?

── TESTANDO ────────────────────────────────────────

[ ] *spec "descricao"           (documentar mudanca)
[ ] *audit-spec --auto          (testar features)
[ ] Veredicto: GO / CONDICIONAL / NO-GO

── PREPARANDO DEPLOY ───────────────────────────────

[ ] *pre-deploy                 (checklist granular)
[ ] Li o checklist inteiro
[ ] Total de correcoes: ___

── FAZENDO DEPLOY ──────────────────────────────────

[ ] git pull origin main
[ ] Copiei JSONs para /tmp/deploy_n8n/
[ ] Apliquei TODAS as ___ correcoes
[ ] Conferi: marquei TODOS os itens
[ ] Desativei workflows em PROD
[ ] Importei JSONs corrigidos
[ ] Reativei workflows
[ ] Conferi logs: docker logs totalassistente-n8n --tail 50

── VALIDANDO ───────────────────────────────────────

[ ] *validate-prod              (escanear PROD)
[ ] Veredicto: ALL_CLEAR / ISSUES / CRITICAL

── SE DEU ERRADO ───────────────────────────────────

[ ] "RESTAURAR GOLDEN BACKUP"


Data: ___/___/______    Versao: _________
```
