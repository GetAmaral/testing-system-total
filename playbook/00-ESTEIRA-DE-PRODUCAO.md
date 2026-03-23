# Esteira de Producao — Total Assistente

## O que e isso?

Este e o seu processo padrao. Toda vez que voce for mexer no sistema — seja uma feature nova, um fix, ou um ajuste — voce segue esta esteira. Sem pular etapas. Sem atalhos.

```
IDEIA → SNAPSHOT → MUDANCA → SNAPSHOT → DIFF → TESTE → CHECKLIST → DEPLOY → VALIDACAO
```

---

## Regra de Ouro

> **Nunca deployar sem passar por todas as etapas.**
> Se pulou uma, volte. A esteira existe para proteger voce.

---

## Documentos desta pasta

| # | Documento | Quando ler |
|---|-----------|------------|
| 01 | [Playbook Completo](01-PLAYBOOK.md) | Toda vez que for fazer qualquer mudanca |
| 02 | [Checklist Rapido (cola)](02-CHECKLIST-RAPIDO.md) | Imprima e cole do lado do monitor |
| 03 | [Cenarios Comuns](03-CENARIOS.md) | Quando quiser ver como aplicar em situacoes reais |
| 04 | [Quando Algo Da Errado](04-EMERGENCIA.md) | Quando deployou e quebrou |

---

## Inicio em 10 segundos

```
@guardian
*snapshot pre-{nome}
(faz mudanca)
*snapshot pos-{nome}
*diff --latest
*spec
*audit-spec --auto
*pre-deploy
(faz deploy seguindo checklist)
*validate-prod
```
