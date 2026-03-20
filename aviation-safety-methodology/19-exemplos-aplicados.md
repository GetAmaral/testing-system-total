# 19 — Exemplos Aplicados: Erros Reais Reescritos com Template v2

> Os erros ERR-001 e ERR-011 reescritos com o novo formato
> para demonstrar a diferença prática.

---

## Exemplo 1: ERR-001 Reescrito (Registro de Gasto Falhou)

```markdown
# ERR-001 — FIN-01: FAIL

**Data:** 2026-03-20T14:30:00-03:00
**Teste:** FIN-01
**Funcionalidade:** financeiro/01-despesas-receitas
**Operação:** CRIAR_GASTO
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Classificação de Severidade (HFACS/SMS)

| Campo | Valor |
|-------|-------|
| **Severidade** | 🔴 S1 (Crítico) |
| **Tipo (TEM)** | SIL (Falha Silenciosa) |
| **Componente** | N8N-FIN (Financial Workflow) |
| **Impacto** | Perda financeira (dado não persistido, usuário acredita que registrou) |
| **Frequência** | Isolado (1) |
| **Priority Score** | 82 = (1.0×40)+(0.25×30)+(1.0×30) |

### Critério de Severidade Aplicado
> S1 porque o gasto NÃO foi registrado no banco mas o sistema pode ter
> dado a impressão de sucesso ao usuário. Dado financeiro perdido é
> irrecuperável se o usuário não perceber e não repetir.

---

## O que era esperado
Ao enviar "gastei 38 no acai", o sistema deveria:
1. Classificar como `criar_gasto`
2. Extrair: nome="Açaí", valor=38, categoria="Alimentação"
3. Insertar na tabela `spent`
4. Responder confirmando o registro

## O que aconteceu
- Webhook recebeu a mensagem (exec 11641 - Main OK)
- Report workflow (exec 11644) falhou com erro
- Registro NÃO encontrado na tabela `spent`
- Contagem da tabela não alterou (90 → 90)

---

## Cadeia de Rastreabilidade Completa (Flight Data Record)

| Camada | Status | Evidência |
|--------|--------|-----------|
| **L1 — Webhook** | ✅ | Exec 11641 (Main) recebeu mensagem, status success |
| **L2 — Classificação** | ⚠️ | Branch não capturado (não logado). Inferido: `criar_gasto` |
| **L3 — Contexto (Redis)** | ❓ | Não verificado — sem acesso ao estado Redis no momento |
| **L4 — LLM Decision** | ❓ | Resposta da IA NÃO CAPTURADA. Tools chamadas desconhecidas |
| **L5 — Execução da Ação** | ❌ | Registro NOT_FOUND na tabela `spent`. Contagem 90→90 |
| **L6 — Resposta ao Usuário** | ❓ | Texto da resposta NÃO CAPTURADO |

### Ponto Exato de Falha
> **Camada L5 — N8N-FIN:** O workflow Report (exec 11644) falhou, e o registro
> não foi persistido na tabela `spent`. A falha no Report pode ter interrompido
> o pipeline antes do INSERT, ou o INSERT falhou silenciosamente.

---

## Resposta da IA (CVR)

- **log_id:** [não capturado]
- **Branch classificado:** [não capturado — GAP CRÍTICO]
- **Mensagem completa da IA:**
> ⚠️ **NÃO CAPTURADA** — Este é o gap mais crítico. Sem a resposta,
> não sabemos se a IA confirmou o registro (dando falsa segurança ao usuário)
> ou se indicou erro.
- **Tools chamadas:** [desconhecido]

---

## Execuções N8N envolvidas

| Exec ID | Workflow | Status | Duração | Erro |
|---------|----------|--------|---------|------|
| 11641 | Main - Total Assistente | ✅ | — | — |
| 11644 | Report Unificado | ❌ | — | Mensagem de erro NÃO CAPTURADA |

### Workflows com erro (detalhado):
> **Report Unificado (11644):**
> - **Nó que falhou:** NÃO IDENTIFICADO (necessário GET /api/v1/executions/11644)
> - **Input do nó:** Desconhecido
> - **Output/Erro:** Desconhecido — PRECISA SER INVESTIGADO

---

## Estado do Banco

### Snapshots
| Tabela | ANTES | DEPOIS | Δ | Esperado | Match? |
|--------|-------|--------|---|----------|--------|
| spent | 90 | 90 | 0 | +1 | ❌ |
| calendar | 318 | 318 | 0 | 0 | ✅ |

### Registro Específico
> Busca por nome "Açaí" ou "acai" na tabela `spent`: **NOT_FOUND**

---

## KPIs do Teste

| KPI | Valor | Peso | Descrição |
|-----|-------|------|-----------|
| Funcional | 0 | 0.30 | Gasto NÃO foi registrado |
| Banco | 0 | 0.25 | Tabela não alterou |
| N8N | 0 | 0.15 | Report workflow falhou |
| Consistência | 0 | 0.20 | Sem resposta IA para comparar |
| Tempo | 1 | 0.10 | Webhook respondeu rapidamente |
| **Score Ponderado** | **0.10** | — | Apenas tempo OK |

### Ajuste por Domínio
> Score final = 0.10 × 1.5 (financeiro) = **0.15** (arredondado)
> ⚠️ Score baixíssimo para domínio financeiro.

---

## Análise de Causa Raiz (5 Porquês)

```
Gasto "Açaí R$38" não foi registrado no banco
  └── Por quê? O INSERT na tabela `spent` não aconteceu
       └── Por quê? O workflow Report (11644) falhou antes ou durante o INSERT
            └── Por quê? [NECESSITA INVESTIGAÇÃO — buscar exec 11644 no N8N]
                 └── Por quê? [Possível: pipeline Report tenta gerar relatório
                      antes de confirmar INSERT, e falha no Report aborta tudo]
                      └── CAUSA RAIZ PROVÁVEL: Acoplamento entre registro de gasto
                          e geração de relatório — falha em um impede o outro.
                          ⚠️ Requer confirmação via análise do workflow.
```

### Classificação HFACS

| Nível HFACS | Presente? | Detalhe |
|-------------|-----------|---------|
| **Ato inseguro** | Não | Não houve erro humano |
| **Precondição** | Sim | Acoplamento entre workflows (Report + Financial) |
| **Supervisão** | Sim | Sem logging do branch ou da resposta IA |
| **Organizacional** | Sim | Decisão de não implementar logging no pipeline financeiro |

### Classificação Just Culture

| Categoria | Aplicável? | Justificativa |
|-----------|-----------|---------------|
| **Erro do sistema** | ✅ Sim | Bug de acoplamento entre workflows |
| **Comportamento de risco** | ✅ Sim | Ausência de logging = risco conhecido não mitigado |
| **Negligência** | Não | Não há evidência de decisão deliberada |

---

## Medidas Corretivas e Preventivas

### Correção Imediata
1. **Investigar exec 11644:** `GET /api/v1/executions/11644?includeData=true` para identificar nó exato
2. **Desacoplar Report de Financial:** INSERT no `spent` não deve depender do sucesso do Report
3. **Capturar resposta IA:** Garantir que log_users_messages capture a ai_message

### Prevenção
1. **Logging obrigatório no pipeline financeiro:** Implementar execution_log em N8N-FIN
2. **Teste de regressão:** Adicionar FIN-01 à bateria de regressão com verificação campo-a-campo
3. **Circuit breaker:** Se Report falha, INSERT no `spent` deve continuar independente

### Detecção
1. **Monitor:** Alerta quando contagem de `spent` não incrementa após webhook com branch `criar_gasto`
2. **Heartbeat:** Check diário se últimos N gastos têm log_users_messages correspondente

---

## Ciclo de Vida do Erro

| Fase | Status | Data | Responsável | Notas |
|------|--------|------|-------------|-------|
| 📋 Documentado | ✅ | 2026-03-20 | @auditor | Este documento |
| 🔍 Investigado | ⬜ | — | @deep-agent | Pendente: buscar exec 11644 |
| 🔧 Corrigido | ⬜ | — | @dev | Pendente: desacoplar Report |
| ✅ Verificado | ⬜ | — | @auditor | Pendente: reteste FIN-01 |
| 🔒 Fechado | ⬜ | — | @commander | — |

---

## Padrões Relacionados

- **Erros similares:** ERR-002, ERR-003 (também têm N8N Report errors)
- **Padrão detectado:** SIM — Report workflow falha frequentemente (8 de 25 testes)
  sem impactar funcionalidade (score 0.75), mas neste caso IMPACTOU.
- **Tendência:** ➡️ Estável — Report errors são recorrentes mas normalmente não-blocking.
  ERR-001 é exceção onde Report error BLOQUEOU a operação principal.

---

*Erro documentado por @auditor (Lupa) — Auditoria 360 v2*
*Metodologia: Swiss Cheese (6 camadas), HFACS (4 níveis), 5-Why, Just Culture, TEM*
```

---

## Exemplo 2: FIN-05 (PASS) — Log Reescrito

> Demonstrando que mesmo testes que PASSAM geram aprendizado.

```markdown
# FIN-05 — EXCLUIR_GASTO

**Funcionalidade:** financeiro/01-despesas-receitas
**Data:** 2026-03-20T15:10:00-03:00
**Ambiente:** DEV (http://76.13.172.17:5678)
**Duração total do teste:** 28s (incluindo 20s async wait)

---

## Veredicto

### **PASS**

| Dimensão | Score | Detalhe |
|----------|-------|---------|
| **Compreensão** (0.25) | 1.0 | IA entendeu "exclui o açaí" corretamente |
| **Precisão** (0.25) | 1.0 | Registro correto excluído |
| **Completude** (0.15) | 1.0 | Exclusão completa, sem resíduos |
| **Persistência** (0.20) | 1.0 | Contagem de spent decrementou corretamente |
| **Contexto** (0.10) | 1.0 | Sabia qual "açaí" era (último registrado) |
| **Tom** (0.05) | 1.0 | Confirmou exclusão de forma clara |
| **Score Final** | **1.00** | Perfeito |

### Classificação Rápida (TEM)
- **Ameaças detectadas:** Operação async (20s delay entre confirmação e banco)
- **Erros encontrados:** Nenhum
- **Estado indesejado:** Nenhum

---

## O que era esperado
"exclui o açaí" → Excluir registro de gasto "Açaí" → Contagem de spent -1

## O que aconteceu
- IA reconheceu "açaí" como referência ao gasto mais recente
- Confirmou exclusão na resposta
- Após 20s async wait, registro removido e contagem decrementou

### Pontos positivos
- Resolução contextual perfeita ("o açaí" → registro específico)
- Operação completou dentro do tempo esperado

### Pontos negativos
- 20s de delay entre confirmação da IA e efetivação no banco (async)

---

## Cadeia de Rastreabilidade (6 Camadas)

### Mensagem Enviada
```
exclui o açaí
```

### L1 — Recepção
- **HTTP Status:** 200
- **Exec ID:** 11668

### L2 — Classificação
- **Branch selecionado:** `excluir`
- **Branch esperado:** `excluir`
- **Correto?** ✅

### L3 — Contexto
- **Contexto preservado?** ✅ (sabia qual "açaí" era)

### L4 — Resposta da IA
```
✅ Gasto excluído!

📝 Nome: Açaí
💰 Valor: R$38,00
📚 Categoria: Alimentação
```
- **Tools chamadas:** delete_spent
- **JSON:** `{"acao": "excluir_gasto", "id": "cb191519-..."}`

### L5 — Execução
- **Tabela:** spent
- **Operação:** DELETE
- **Resultado:** ✅ Registro removido (verificado após 20s)

### L6 — Entrega
- **Entregue:** ✅
- **Tempo total:** ~8s (resposta) + 20s (async) = 28s total

---

## Estado do Banco

| Tabela | ANTES | DEPOIS | Δ | Esperado | Match? |
|--------|-------|--------|---|----------|--------|
| spent | 91 | 90 | -1 | -1 | ✅ |

---

## Aprendizado (LOSA + Kaizen)

### O que este teste ensina?
> Operação DELETE funciona corretamente, mas o delay async de 20s entre
> a confirmação da IA e a efetivação no banco é uma AMEAÇA latente.
> Se o usuário verificar seus gastos imediatamente após a exclusão,
> ainda verá o registro por ~20s, potencialmente causando confusão.

### Ameaças observadas (TEM)
> - **Async delay (20s):** Janela onde banco está inconsistente com resposta da IA
> - **Sem rollback:** Se o DELETE falhar após a IA confirmar, não há mecanismo de retry

### Gera erro? Não

---

*Teste executado por @auditor (Lupa) — Auditoria 360 v2*
```

---

## Comparação Visual: v1 vs v2

### ERR-001 v1 (original) — ~25 linhas úteis
- Criticidade: "A INVESTIGAR"
- Resposta IA: [vazia]
- Causa raiz: template genérico
- Prevenção: nenhuma
- Resolução: nenhuma

### ERR-001 v2 (aviation) — ~120 linhas úteis
- Severidade: S1 com justificativa + priority score 82
- Resposta IA: capturada (ou gap explicitamente marcado)
- Causa raiz: 5-Why + HFACS 4 níveis + Just Culture
- Prevenção: 3 níveis (correção + prevenção + detecção)
- Resolução: ciclo PDCA com 5 fases e responsáveis

**A diferença é: v1 documenta o acidente. v2 previne o próximo.**
