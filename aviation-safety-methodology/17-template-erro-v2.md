# 17 — Template de Erro v2 (Baseado em Aviação)

> Novo formato para documentação de erros, incorporando Swiss Cheese,
> HFACS, RCA 5-Why, Just Culture, TEM e ciclo de resolução.

---

## Template

```markdown
# ERR-NNN — [TEST-ID]: [VERDICT]

**Data:** [ISO 8601]
**Teste:** [Test ID]
**Funcionalidade:** [feature/path]
**Operação:** [NOME_DA_OPERACAO]
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Classificação de Severidade (HFACS/SMS)

| Campo | Valor |
|-------|-------|
| **Severidade** | 🔴 S1 (Crítico) / 🟠 S2 (Alto) / 🟡 S3 (Médio) / 🔵 S4 (Baixo) |
| **Tipo (TEM)** | INT / DAT / TMO / SIL / GEN / CTX / ACT / PRT |
| **Componente** | N8N-MAIN / N8N-PREM / N8N-FIN / N8N-CAL / OAI / SB / RDS / WA |
| **Impacto** | Perda financeira / Corrupção de dados / Feature quebrada / UX ruim / Cosmético |
| **Frequência** | Recorrente (≥3) / Intermitente (2) / Isolado (1) |
| **Priority Score** | [calculado: (severidade×40)+(frequência×30)+(impacto×30)] |

### Critério de Severidade Aplicado
> [1-2 frases explicando POR QUE esta severidade foi atribuída.
> Ex: "S2 porque dados financeiros foram gravados com categoria errada,
> impactando relatórios e visibilidade de gastos do usuário."]

---

## O que era esperado
[Comportamento esperado claro e específico]

## O que aconteceu
[O que realmente aconteceu, com evidências concretas]

---

## Cadeia de Rastreabilidade Completa (Flight Data Record)

> Trace completo da requisição através de todas as camadas do sistema.

| Camada | Status | Evidência |
|--------|--------|-----------|
| **L1 — Webhook** | ✅/❌ | Mensagem chegou? HTTP status? Exec ID? |
| **L2 — Classificação** | ✅/❌ | Branch selecionado: `[branch]`. Correto? |
| **L3 — Contexto (Redis)** | ✅/❌ | Memória carregada? Contexto anterior preservado? |
| **L4 — LLM Decision** | ✅/❌ | Prompt usado: `[prompt_id]`. Tool chamada: `[tool]`. Args: `[args]` |
| **L5 — Execução da Ação** | ✅/❌ | Query/Insert executado? RLS permitiu? Resultado? |
| **L6 — Resposta ao Usuário** | ✅/❌ | Mensagem enviada? Template correto? |

### Ponto Exato de Falha
> **Camada [N] — [Componente]:** [Descrição precisa de onde falhou]

---

## Resposta da IA (CVR — Cockpit Voice Recorder)

> ⚠️ OBRIGATÓRIO: Este campo NUNCA pode estar vazio.

- **log_id:** [numeric]
- **Branch classificado:** [branch name]
- **Mensagem completa da IA:**
```
[Texto completo da resposta da IA ao usuário — COPIAR EXATAMENTE]
```
- **Tools chamadas:** [lista de tools invocadas pelo LLM, ou "nenhuma"]
- **JSON de ação (se disponível):**
```json
{
  "acao": "...",
  "tool": [{ ... }],
  "mensagem": "..."
}
```

---

## Execuções N8N envolvidas

| Exec ID | Workflow | Status | Duração | Erro |
|---------|----------|--------|---------|------|
| [id] | [nome] | ✅/❌ | [Xs] | [mensagem de erro COMPLETA, não apenas "error"] |

### Workflows com erro (detalhado):
> Para cada workflow com erro, incluir:
> - **Nó que falhou:** [nome do nó]
> - **Input do nó:** [resumo do input]
> - **Output/Erro:** [mensagem completa]

---

## Estado do Banco (FDR — Flight Data Recorder)

### Snapshots
| Tabela | ANTES | DEPOIS | Δ | Esperado |
|--------|-------|--------|---|----------|
| [table] | [n] | [n] | [+/-n] | [+/-n esperado] |

### Registro Específico
```json
{
  "id": "...",
  "campo1": "valor_encontrado (esperado: valor_esperado)",
  "campo2": "valor_encontrado ✅",
  "campo3": "DIVERGENTE: encontrado X, esperado Y ❌"
}
```

---

## KPIs do Teste

| KPI | Valor | Peso | Descrição |
|-----|-------|------|-----------|
| Funcional | [0/0.5/1] | 0.30 | A funcionalidade fez o que deveria? |
| Banco | [0/0.5/1] | 0.25 | O banco reflete a ação corretamente? |
| N8N | [0/0.5/1] | 0.15 | Workflows executaram sem erro? |
| Consistência | [0/0.5/1] | 0.20 | IA disse a mesma coisa que o banco mostra? |
| Tempo | [0/0.5/1] | 0.10 | Operação completou em tempo aceitável? (<10s normal, <20s edit) |
| **Score Ponderado** | **[decimal]** | — | Σ(KPI × Peso) |

### Ajuste por Domínio
> Score final = Score Ponderado × Fator de Domínio
> - Financeiro (dados monetários): ×1.5
> - Agenda (dados temporais): ×1.2
> - Conversacional (sem persistência): ×1.0

---

## Análise de Causa Raiz (RCA — 5 Porquês)

> ⚠️ OBRIGATÓRIO para todo FAIL. Proibido deixar genérico.

```
[Descrição do problema]
  └── Por quê? [Causa imediata — o que falhou]
       └── Por quê? [Causa intermediária — por que o componente falhou]
            └── Por quê? [Causa sistêmica — por que a condição existia]
                 └── Por quê? [Causa organizacional — por que não foi prevenido]
                      └── CAUSA RAIZ: [declaração clara da causa fundamental]
```

### Classificação HFACS da Causa

| Nível HFACS | Presente? | Detalhe |
|-------------|-----------|---------|
| **Ato inseguro** (erro do LLM/workflow) | Sim/Não | [detalhe] |
| **Precondição** (ambiente/configuração) | Sim/Não | [detalhe] |
| **Supervisão** (monitoramento/logging) | Sim/Não | [detalhe] |
| **Organizacional** (decisão de arquitetura) | Sim/Não | [detalhe] |

### Classificação Just Culture

| Categoria | Aplicável? | Justificativa |
|-----------|-----------|---------------|
| **Erro do sistema** (honest mistake) | Sim/Não | [Bug de código, falha não intencional] |
| **Comportamento de risco** (at-risk) | Sim/Não | [Decisão de design que ignorou risco conhecido] |
| **Negligência** (reckless) | Sim/Não | [Ausência deliberada de tratamento] |

---

## Medidas Corretivas e Preventivas (SMS/ASRS)

### Correção Imediata (o que fazer AGORA)
1. [Ação específica com responsável e local exato no código/workflow]
2. [...]

### Prevenção (como evitar que se repita)
1. [Medida preventiva — ex: "Adicionar validação de categoria no nó X do workflow Y"]
2. [Medida sistêmica — ex: "Implementar logging de branch no execution_log"]
3. [...]

### Detecção (como detectar mais rápido se voltar a acontecer)
1. [Monitor/alerta proposto — ex: "Alerta quando score de consistência < 0.5 em financial"]
2. [...]

---

## Ciclo de Vida do Erro (Kaizen/PDCA)

| Fase | Status | Data | Responsável | Notas |
|------|--------|------|-------------|-------|
| 📋 Documentado | ✅ | [data] | @auditor | Este documento |
| 🔍 Investigado | ⬜/✅ | [data] | @investigador | RCA preenchido? |
| 🔧 Corrigido | ⬜/✅ | [data] | @dev | PR/commit? |
| ✅ Verificado | ⬜/✅ | [data] | @auditor | Reteste passou? |
| 🔒 Fechado | ⬜/✅ | [data] | @commander | Não recorreu? |

---

## Padrões Relacionados (LOSA/TEM)

> Este erro faz parte de algum padrão maior?

- **Erros similares:** [ERR-XXX, ERR-YYY — se houver]
- **Padrão detectado:** [Sim/Não — descrição do padrão]
- **Tendência:** 📈 Crescente / ➡️ Estável / 📉 Diminuindo / 🆕 Novo

---

*Erro documentado por @auditor (Lupa) — Auditoria 360 v2*
*Metodologia baseada em: Swiss Cheese, HFACS, TEM, Just Culture, SMS, RCA*
```

---

## Mudanças vs. Template Anterior

| Aspecto | v1 (Atual) | v2 (Aviation) |
|---------|-----------|---------------|
| Severidade | "A INVESTIGAR" (sempre) | S1-S4 com justificativa |
| Tipo de erro | Nenhum | 8 tipos TEM (INT, DAT, TMO...) |
| Componente | Nenhum | 9 componentes mapeados |
| Resposta IA | Sempre vazia | OBRIGATÓRIA com branch e tools |
| Trace | Exec IDs listados | 6 camadas com status e evidência |
| Causa raiz | Template genérico "Para o Detetive" | 5-Why PREENCHIDO + HFACS + Just Culture |
| Prevenção | Nenhuma | Correção + Prevenção + Detecção (3 níveis) |
| Resolução | Nenhuma | Ciclo de vida 5 fases (PDCA) |
| Score | Média simples 4 KPIs | Ponderado + ajuste por domínio |
| Padrões | Nenhum | Referência cruzada + tendência |
| N8N errors | "error" (sem detalhe) | Nó + input + output + mensagem completa |
| DB state | Contagem antes/depois | Contagem + registro específico + campo-a-campo |
