# Relatorio de Auditoria de Spec — {titulo}

**Data**: {date}
**Spec**: {spec_path}
**Auditor**: Vigil (Guardian) com delegacao para @testador e @auditor-360

---

## Veredicto

```
{emoji} {GO|NO-GO|CONDICIONAL} — {justificativa}
```

---

## Criterios de Aceite

| # | Criterio | Resultado | Evidencia |
|---|----------|-----------|-----------|
| 1 | {criterio} | PASS/FAIL/PARTIAL/UNTESTABLE | {evidencia} |

### Resumo
- **PASS**: {n_pass}
- **FAIL**: {n_fail}
- **PARTIAL**: {n_partial}
- **UNTESTABLE**: {n_untestable}

---

## Avaliacao de Qualidade

| Dimensao | Score | Detalhes |
|----------|-------|----------|
| Funciona? | {x}/10 | {detalhes} |
| E util? | {x}/10 | {detalhes} |
| E escalavel? | {x}/10 | {detalhes} |
| Performance OK? | {x}/10 | {detalhes} |
| Seguro? | {x}/10 | {detalhes} |

---

## Testes Funcionais (via @testador)

| Teste | Comando | Resultado | Detalhes |
|-------|---------|-----------|----------|
| {teste} | {comando} | PASS/FAIL | {detalhes} |

---

## Regressoes Detectadas

| Feature | Status | Severidade | Detalhes |
|---------|--------|------------|----------|
| {feature} | OK/REGRESSAO | {sev} | {detalhes} |

---

## Recomendacoes

1. {recomendacao_1}
2. {recomendacao_2}

---

## Proximo Passo

- Se GO: `*pre-deploy` para gerar checklist de deploy
- Se CONDICIONAL: corrigir issues e re-executar `*audit-spec`
- Se NO-GO: corrigir problemas criticos antes de deployar

---

*Gerado pelo Guardian Deploy Squad - Vigil*
