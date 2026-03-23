# Documentacao — Total Assistente Testing System

## Sobre

Documentacao completa do sistema de testes, deploy e qualidade do Total Assistente.
Inclui o squad Guardian Deploy (copiloto de deploy), a esteira de producao, e guias de emergencia.

---

## Comece Por Aqui (Didatico)

Explicacoes simples, com analogias e exemplos visuais.

| # | Documento | O que explica |
|---|-----------|---------------|
| 01 | [O Que E o Guardian Deploy](01-o-que-e-guardian.md) | O que e, por que existe, como funciona (analogia: copiloto de aviao) |
| 02 | [Como Usar — Passo a Passo](02-como-usar.md) | Cada comando com exemplos reais, 4 cenarios completos |
| 03 | [DEV vs PROD — Nunca Confunda](03-dev-vs-prod.md) | Diferencas entre ambientes, tabelas visuais, 4 armadilhas |

---

## Esteira de Producao (Processo)

O processo padrao que voce segue SEMPRE ao fazer mudancas e deploy.

| # | Documento | Quando usar |
|---|-----------|-------------|
| 04 | [Playbook — Esteira Completa](04-playbook-esteira.md) | Toda vez que for fazer qualquer mudanca (10 fases) |
| 05 | [Checklist Rapido (cola)](05-checklist-rapido.md) | Imprima e cole do lado do monitor |
| 06 | [Cenarios Comuns](06-cenarios-comuns.md) | Feature nova, bug fix, prompt, refactor, re-deploy |
| 07 | [Quando Algo Da Errado](07-emergencia.md) | 3 niveis de problema + rollback + prevencao |

---

## Tecnico (Arquitetura e Referencia)

Para entender a fundo como o sistema funciona internamente.

| # | Documento | O que cobre |
|---|-----------|-------------|
| 08 | [Arquitetura do Squad](08-arquitetura-tecnica.md) | Componentes, 7 camadas seguranca, mapa de delegacao, fluxo de dados |
| 09 | [Referencia de Tasks e Workflows](09-referencia-tasks-workflows.md) | Cada task/workflow: inputs, outputs, 5 scans, veredictos |
| 10 | [Data Files e Mapeamentos](10-data-files.md) | Todos os YAMLs: environments, deploy-rules, credentials, workflow IDs |

---

## Inicio Rapido (30 segundos)

```
@guardian
*snapshot pre-{nome}
(faz mudanca no N8N DEV)
*snapshot pos-{nome}
*diff --latest
*spec "descricao"
*audit-spec --auto
*pre-deploy
(faz deploy seguindo checklist)
*validate-prod
```

---

## Links Uteis

| Recurso | URL |
|---------|-----|
| N8N DEV | http://76.13.172.17:5678 |
| N8N PROD | https://n8n.totalassistente.com.br |
| Squad Guardian | [guardian-deploy/](../guardian-deploy/) |
| Playbook (antigo) | [playbook/](../playbook/) |
