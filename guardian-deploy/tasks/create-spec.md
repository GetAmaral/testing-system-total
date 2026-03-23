---
task: Create Change Specification
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - description: string (required) - Descricao do que mudou e por que
  - diff_report: string (optional) - Path do diff report para auto-detectar mudancas
Saida: |
  - spec_file: .md em output/specs/{date}-spec-{slug}.md
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Obter descricao do usuario sobre a mudanca"
  - "[ ] Se existe diff report, extrair mudancas automaticamente"
  - "[ ] Mapear features impactadas (referencia auditor-360)"
  - "[ ] Definir criterios de aceite"
  - "[ ] Gerar spec usando template"
  - "[ ] Salvar em output/specs/"
---

# *spec

Cria uma especificacao de mudanca documentando O QUE mudou, POR QUE mudou, e COMO validar. Serve de input para o *audit-spec testar.

## Uso

```
@guardian

*spec
# -> Interativo: pergunta o que mudou e por que

*spec "Adicionei filtro de categoria no financeiro"
# -> Cria spec com descricao fornecida

*spec --from-diff output/diffs/2026-03-23-diff-pre-pos.md
# -> Auto-detecta mudancas a partir do diff report
```

## READ-ONLY GATE (OBRIGATORIO)

- SOMENTE leitura de arquivos locais
- Output SOMENTE em `squads/guardian-deploy/output/specs/`

## Elicitacao

```
? O que voce mudou nos workflows DEV? (descreva em linguagem natural)
  > [texto livre, obrigatorio]

? Por que fez essa mudanca? (qual problema resolveu ou feature adicionou)
  > [texto livre, obrigatorio]

? Quais workflows foram afetados?
  1. Main - Total Assistente
  2. Calendar WebHooks - Total Assistente
  3. Financeiro - Total
  4. User Premium - Total
  5. User Standard - Total
  6. Lembretes Total Assistente
  7. Relatorios Mensais-Semanais
  > [multipla selecao]

? Existe um diff report para referencia?
  1. Sim (informar path)
  2. Nao (gerar spec apenas com descricao)
  > [selecao]
```

## Fluxo de Execucao

```
1. COLETA DE INFORMACOES
   ├── Obter descricao do usuario
   ├── Obter motivacao (por que mudou)
   ├── Obter workflows afetados
   └── Se existe diff report: carregar e extrair mudancas

2. MAPEAMENTO DE FEATURES
   ├── Para cada workflow afetado, mapear quais das 28 features do auditor-360 sao impactadas:
   │   ├── Financeiro - Total -> financeiro/01 a 04
   │   ├── Calendar WebHooks -> agenda/01 a 08
   │   ├── Main - Total Assistente -> bot-whatsapp/01 a 06
   │   ├── User Premium -> bot-whatsapp/02, todas features premium
   │   └── User Standard -> bot-whatsapp/03, features standard
   └── Gerar lista de features impactadas

3. CRITERIOS DE ACEITE
   ├── Para cada feature impactada, gerar criterio:
   │   ├── "Feature X continua funcionando apos mudanca"
   │   ├── "Nova funcionalidade Y funciona conforme descricao"
   │   └── "Nenhuma regressao nas features adjacentes"
   ├── Criterios de seguranca:
   │   ├── "Nenhuma credential exposta"
   │   ├── "Nenhuma URL de dev em codigo"
   │   └── "Nenhum acesso nao-autorizado"
   └── Criterios de performance:
       ├── "Tempo de resposta nao aumentou significativamente"
       └── "Nenhum loop infinito ou bottleneck introduzido"

4. GERAR SPEC
   ├── Usar template spec-tmpl.md
   ├── Secoes:
   │   ├── Objetivo (o que mudou e por que)
   │   ├── Workflows afetados (lista)
   │   ├── Mudancas detalhadas (do diff se disponivel)
   │   ├── Features impactadas (mapeamento auditor-360)
   │   ├── Comportamento esperado (como deve funcionar apos mudanca)
   │   ├── Criterios de aceite (lista testavel)
   │   └── Riscos conhecidos
   └── Salvar em output/specs/{date}-spec-{slug}.md

5. APRESENTAR RESULTADO
   ├── Resumo da spec gerada
   ├── Numero de criterios de aceite
   ├── Sugestao: "Use *audit-spec {spec_path} para testar"
   └── HALT — aguardar proximo comando
```

## Metadata

```yaml
version: 1.0.0
dependencies:
  - templates/spec-tmpl.md
  - Mapeamento de features do auditor-360
  - diff report (opcional)
tags:
  - spec
  - specification
  - change-management
  - spec-audit
```
