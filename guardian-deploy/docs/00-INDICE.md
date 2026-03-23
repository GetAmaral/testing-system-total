# Guardian Deploy — Documentacao Completa

## Para que serve este squad?

O **Guardian Deploy** e o seu copiloto de deploy. Ele existe para resolver um problema simples:
**voce esquece coisas quando faz deploy manual**. URLs, credentials, nodes fake, pinData...
ele encontra TUDO e gera um checklist para voce ir marcando.

---

## Documentacao Didatica (comece por aqui)

Explicacoes simples, com exemplos visuais e analogias do dia a dia.

| # | Documento | O que explica |
|---|-----------|---------------|
| 01 | [O Que E o Guardian Deploy](01-DIDATICO-o-que-e.md) | O que e, por que existe, como funciona (analogia: copiloto de aviao) |
| 02 | [Como Usar — Passo a Passo](02-DIDATICO-como-usar.md) | Cada comando explicado com exemplos reais, na ordem certa |
| 03 | [DEV vs PROD — Nunca Confunda](03-DIDATICO-dev-vs-prod.md) | As diferencas entre os dois ambientes, com tabela visual |

## Documentacao Tecnica (para entender a fundo)

Estrutura interna, arquitetura, fluxos de dados e decisoes de design.

| # | Documento | O que cobre |
|---|-----------|-------------|
| 04 | [Arquitetura do Squad](04-TECNICO-arquitetura.md) | Componentes, dependencias, guardrails, mapa de delegacao |
| 05 | [Referencia de Tasks e Workflows](05-TECNICO-referencia.md) | Cada task e workflow em detalhe: inputs, outputs, fluxos, scans |
| 06 | [Data Files e Mapeamentos](06-TECNICO-data-files.md) | Todos os YAMLs de dados: environments, deploy-rules, credentials, workflow IDs |

---

## Inicio Rapido (30 segundos)

```
1. Ative:     @guardian
2. Snapshot:  *snapshot pre-v3.1
3. (faca suas mudancas no N8N DEV)
4. Snapshot:  *snapshot pos-v3.1
5. Diff:      *diff --latest
6. Checklist: *pre-deploy
7. (execute o deploy seguindo o checklist)
8. Valide:    *validate-prod
```
