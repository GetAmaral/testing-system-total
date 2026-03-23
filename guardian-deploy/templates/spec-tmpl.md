# Spec de Mudanca — {titulo}

**Data**: {date}
**Autor**: {usuario} (documentado por Vigil)
**Diff de referencia**: {diff_path}

---

## Objetivo

{descricao_do_que_mudou_e_por_que}

---

## Workflows Afetados

| Workflow | Tipo de Mudanca | Impacto |
|----------|-----------------|---------|
| {name} | {tipo} | {impacto} |

---

## Mudancas Detalhadas

{detalhes_das_mudancas_extraidos_do_diff_ou_descricao_do_usuario}

---

## Features Impactadas (ref. auditor-360)

| Feature | Categoria | Task File | Impacto |
|---------|-----------|-----------|---------|
| {feature_name} | {categoria} | {task_path} | Direto/Indireto |

---

## Comportamento Esperado

Apos a mudanca:
- {comportamento_1}
- {comportamento_2}

---

## Criterios de Aceite

### Funcionais
- [ ] {criterio_funcional_1}
- [ ] {criterio_funcional_2}

### Regressao
- [ ] {feature_adjacente_1} continua funcionando
- [ ] {feature_adjacente_2} continua funcionando

### Seguranca
- [ ] Nenhuma credential exposta
- [ ] Nenhuma URL de dev em codigo
- [ ] Nenhum acesso nao-autorizado

### Performance
- [ ] Tempo de resposta nao aumentou significativamente
- [ ] Nenhum loop infinito ou bottleneck introduzido

---

## Riscos Conhecidos

| Risco | Probabilidade | Mitigacao |
|-------|---------------|-----------|
| {risco} | {prob} | {mitigacao} |

---

*Gerado pelo Guardian Deploy Squad - Vigil*
