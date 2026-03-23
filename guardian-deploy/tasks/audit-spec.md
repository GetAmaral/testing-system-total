---
task: Audit Against Specification
responsavel: "@guardian"
responsavel_type: agent
atomic_layer: task
elicit: true
Entrada: |
  - spec_file: string (required) - Path da spec .md gerada por *spec
  - auto_mode: boolean (optional) - Se true, auto-detecta spec mais recente
Saida: |
  - audit_report: .md em output/audits/{date}-spec-audit-{slug}.md
  - verdict: GO | NO-GO | CONDICIONAL
Checklist:
  - "[ ] Executar guardrails-checklist"
  - "[ ] Carregar spec"
  - "[ ] Para cada feature impactada, delegar teste ao squad apropriado"
  - "[ ] Avaliar cada criterio de aceite: PASS / FAIL / PARTIAL / UNTESTABLE"
  - "[ ] Avaliar seguranca, escalabilidade, performance"
  - "[ ] Gerar relatorio de auditoria"
  - "[ ] Emitir veredicto"
---

# *audit-spec

Testa novas features e mudancas contra a especificacao criada por *spec. Avalia se funciona, e util, e escalavel, nao piora performance e o sistema continua seguro.

## Uso

```
@guardian

*audit-spec output/specs/2026-03-23-spec-filtro-categoria.md
# -> Testa contra spec especifica

*audit-spec --auto
# -> Auto-detecta spec mais recente
```

## READ-ONLY GATE (OBRIGATORIO)

- Delegacao para @testador (DEV-only) para testes funcionais
- Delegacao para @auditor-360 (DEV-only) para teste feature-level
- NUNCA acessar producao
- Output SOMENTE em `squads/guardian-deploy/output/audits/`

## Elicitacao

```
? Qual spec auditar?
  1. Usar spec mais recente (output/specs/)
  2. Informar path manualmente
  > [selecao]

? [Se opcao 2] Path da spec:
  > [path]

? Nivel de teste para features impactadas?
  1. Quick (smoke test — rapido, valida se funciona)
  2. Broad (amplo — cenarios principais + edge cases)
  > [selecao, default: 1]

? Testar regressao em features adjacentes?
  1. Sim (recomendado — verifica que nao quebrou nada)
  2. Nao (apenas features impactadas)
  > [selecao, default: 1]
```

## Fluxo de Execucao

```
1. CARREGAR SPEC
   ├── Ler spec .md
   ├── Extrair: features impactadas, criterios de aceite, riscos
   └── Se --auto: buscar spec mais recente em output/specs/

2. TESTE FUNCIONAL (delegar ao @testador)
   ├── Para cada feature impactada:
   │   ├── Se e feature de WhatsApp: *simulate com cenario relevante
   │   ├── Se e feature de webhook: *test-webhook com payload
   │   └── Se e validacao de workflow: *validate {workflow}
   ├── Capturar resultados: PASS / FAIL / PARTIAL
   └── Documentar evidencias

3. TESTE FEATURE-LEVEL (referencia @auditor-360)
   ├── Para cada feature impactada, usar metodologia do auditor-360:
   │   ├── Mapa do sistema (caminho da mensagem)
   │   ├── Endpoints de verificacao
   │   ├── Algoritmo de execucao (snapshot antes, enviar, verificar, comparar)
   │   └── Criterios PASS/FAIL especificos da feature
   └── Nivel de teste: QUICK (smoke test) para cada feature

4. TESTE DE REGRESSAO
   ├── Para features NAO impactadas mas adjacentes:
   │   ├── Smoke test basico para verificar que nao quebraram
   │   └── Comparacao de comportamento antes vs depois
   └── Se regressao detectada: FLAG como CRITICO

5. AVALIACAO DE QUALIDADE
   ├── FUNCIONA? (criterios de aceite passaram?)
   ├── E UTIL? (a mudanca resolve o problema descrito na spec?)
   ├── E ESCALAVEL? (nodes novos criam bottlenecks? loops? N+1?)
   ├── PERFORMANCE OK? (node count cresceu muito? execution time estimado?)
   ├── SEGURO? (credentials expostas? webhook sem auth? dados vazando?)
   └── Para cada avaliacao: score 0-10

6. GERAR RELATORIO
   ├── Usar template spec-audit-report-tmpl.md
   ├── Para cada criterio de aceite: PASS | FAIL | PARTIAL | UNTESTABLE
   ├── Scores de qualidade (funciona, util, escalavel, performance, seguro)
   ├── Regressoes encontradas
   └── Salvar em output/audits/{date}-spec-audit-{slug}.md

7. VEREDICTO
   ├── GO: Todos criterios PASS, sem regressoes, scores >= 7
   ├── CONDICIONAL: Alguns PARTIAL, sem FAILs criticos, scores >= 5
   ├── NO-GO: FAILs criticos, regressoes, scores < 5
   └── HALT — aguardar proximo comando
```

## Metadata

```yaml
version: 1.0.0
dependencies:
  - spec gerada por *spec
  - Delegacao para @testador (Watson)
  - Metodologia do @auditor-360 (Lupa)
  - templates/spec-audit-report-tmpl.md
tags:
  - audit
  - testing
  - spec-driven
  - spec-audit
```
