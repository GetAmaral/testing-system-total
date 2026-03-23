# Diff de Versoes DEV — {v1} vs {v2}

**Data**: {date}
**Analista**: Vigil (Guardian)
**Snapshot Antigo (v1)**: {v1_label} ({v1_date})
**Snapshot Novo (v2)**: {v2_label} ({v2_date})

---

## Resumo Executivo

| Metrica | Valor |
|---------|-------|
| Workflows adicionados | {n_added} |
| Workflows removidos | {n_removed} |
| Workflows modificados | {n_modified} |
| Workflows inalterados | {n_unchanged} |
| **Risco geral** | **{risk_level}** |

### Distribuicao de Mudancas por Tipo

| Tipo | Quantidade |
|------|------------|
| STRUCTURAL (nodes/conexoes) | {n_structural} |
| CONFIG (parametros/settings) | {n_config} |
| PROMPT (AI system messages) | {n_prompt} |
| COSMETIC (posicao/notas) | {n_cosmetic} |

---

## Workflows Adicionados

| Workflow | Nodes | Descricao |
|----------|-------|-----------|
| {name} | {n_nodes} | {descricao} |

---

## Workflows Removidos

| Workflow | Impacto |
|----------|---------|
| {name} | {impacto} |

---

## Workflows Modificados

### {workflow_name}

**Resumo**: {resumo_mudancas}
**Risco**: {risk}

#### Nodes Adicionados
| Node | Tipo | Descricao |
|------|------|-----------|
| {name} | {type} | {descricao} |

#### Nodes Removidos
| Node | Tipo | Impacto |
|------|------|---------|
| {name} | {type} | {impacto} |

#### Nodes Modificados
| Node | Tipo | Campo | Antes | Depois | Risco |
|------|------|-------|-------|--------|-------|
| {name} | {type} | {field} | {old_value} | {new_value} | {risk} |

#### Conexoes Alteradas
| De | Para | Acao |
|----|------|------|
| {source} | {target} | Adicionada/Removida |

#### Prompts AI Modificados (DESTAQUE)
```
--- ANTES ---
{old_prompt}

--- DEPOIS ---
{new_prompt}
```

*(repetir para cada workflow modificado)*

---

## Proximo Passo

- Se mudou features: `*spec` para documentar + `*audit-spec` para testar
- Se pronto para deploy: `*pre-deploy` para gerar checklist granular

---

*Gerado pelo Guardian Deploy Squad - Vigil*
