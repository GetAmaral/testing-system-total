# 16 — Diagnóstico: Formato Atual de Erros e Logs vs. Aviação

> Análise crítica do sistema de auditoria atual do Total Assistente
> à luz das metodologias de segurança da aviação.

---

## 1. Resumo Executivo

O sistema de auditoria atual (auditoria-360) é **bem estruturado para documentação**, mas **inadequado para diagnóstico e prevenção**. Usando a aviação como referência:

- É como ter uma **caixa preta que grava o voo mas não grava a voz do piloto** (resposta da IA sempre vazia)
- É como ter um **HFACS que classifica tudo como "a investigar"** (sem criticidade real)
- É como ter um **LOSA que observa mas nunca gera contramedidas** (sem prevenção)
- É como ter um **FDR sem FDM** — registra o que aconteceu, mas não aprende proativamente

---

## 2. Gap Analysis Detalhado

### 2.1 Resposta da IA — O CVR Silencioso

**Na aviação:** O Cockpit Voice Recorder (CVR) grava TUDO que a tripulação diz. Sem ele, investigadores perdem 50% da informação.

**No sistema atual:** O campo "Resposta da IA" está **vazio em 100% dos 25 testes** (ERR-001 a ERR-012, todos os logs). Há um `log_id` mas sem o texto real.

**Impacto:** Impossível saber:
- O que a IA entendeu da mensagem
- Que branch o classificador escolheu
- Que tools a IA tentou chamar
- Se a resposta ao usuário estava correta

**Equivalente aviação:** Investigar um acidente sem o CVR — só com dados de instrumentos.

---

### 2.2 Criticidade — O HFACS Sem Classificação

**Na aviação:** HFACS classifica cada erro em 19 categorias, 4 níveis, com severidade S1-S4.

**No sistema atual:** Todos os 12 erros têm `Criticidade: A INVESTIGAR`. Nenhum foi realmente classificado. O squad auditor TEM um sistema de classificação (S1-S4, 8 tipos, 9 componentes) mas ele **não é usado nos outputs reais**.

**Impacto:** Sem priorização, a equipe não sabe o que corrigir primeiro.

---

### 2.3 Causa Raiz — RCA Ausente

**Na aviação:** Todo acidente tem 5-Why, Fishbone, e/ou Fault Tree Analysis.

**No sistema atual:** A seção "Para o Detetive" é um template genérico com 4 passos:
```
1. GET /api/v1/executions/{exec_id}
2. Identificar o nó exato que deu error
3. Verificar input/output do nó
4. Classificar criticidade
```
Nunca foi preenchido com análise real. É o equivalente a dizer "investigue o acidente" sem fazer a investigação.

---

### 2.4 Prevenção — ASRS/SMS Inexistentes

**Na aviação:** Cada incidente gera medidas preventivas. O ASRS alimenta mudanças em SOPs, treinamento, e design.

**No sistema atual:** Nenhum erro tem seção de prevenção. Erros são documentados e congelados em "A INVESTIGAR" para sempre. Não há:
- Medidas corretivas definidas
- Medidas preventivas propostas
- Tracking de resolução
- Verificação de não-recorrência

---

### 2.5 Rastreabilidade — A Cadeia Quebrada

**Na aviação:** FDR + CVR + ATC transcripts + manutenção logs = cadeia completa.

**No sistema atual:** A cadeia está quebrada em 4 pontos:

```
Mensagem do usuário ──→ [?] ──→ N8N Webhook ──→ [?] ──→ Classificação
       ↓                            ↓                        ↓
  (capturada)              (exec IDs listados)     (NUNCA capturada)
                                    ↓
                             [?] ──→ LLM Decision ──→ [?] ──→ Tool Call
                                         ↓                      ↓
                                   (resposta VAZIA)     (ação inferida, não capturada)
                                                              ↓
                                                    [?] ──→ Database ──→ Snapshot
                                                                           ↓
                                                                     (contagem antes/depois)
```

**Os [?] são pontos onde informação se perde.**

---

### 2.6 Score — Métrica Sem Risco

**Na aviação:** SMS usa matrizes de risco (probabilidade × severidade). HFACS pesa impacto financeiro, operacional, humano.

**No sistema atual:** Score = média simples de 4 KPIs (0-1). Problemas:
- Score 0.75 = "N8N teve erro mas funcionalidade OK" — tratado como quase perfeito
- Score 0.75 = "dados gravados errado mas IA respondeu" — mesmo score, risco muito diferente
- Sem pesos por criticidade do domínio (erro financeiro ≠ erro cosmético)

---

## 3. O Que Precisa Mudar — Checklist de Melhorias

| # | Gap | Conceito Aviação | Prioridade | Melhoria |
|---|-----|-----------------|-----------|----------|
| 1 | Resposta IA vazia | CVR | P0 | Capturar texto completo da IA + branch classificado |
| 2 | Sem criticidade | HFACS/SMS | P0 | Classificar S1-S4 com fórmula do squad auditor |
| 3 | Sem causa raiz | RCA | P0 | 5-Why obrigatório em todo FAIL |
| 4 | Sem prevenção | SMS/ASRS | P1 | Seção de medidas preventivas em todo erro |
| 5 | Sem resolução | SMS Pilar 3 | P1 | Status tracking: aberto → investigando → corrigido → verificado |
| 6 | Score sem risco | SMS Risk Matrix | P1 | Score ponderado por domínio + severidade |
| 7 | Cadeia quebrada | FDR+CVR | P1 | Trace completo: webhook → classificação → LLM → ação → resposta |
| 8 | Template genérico investigação | Deep-Agent 6 camadas | P2 | Investigação real por camada, não template |
| 9 | Sem padrões | LOSA/TEM | P2 | Detecção de padrões entre erros |
| 10 | Sem lifecycle | Kaizen/PDCA | P2 | Ciclo: documentar → investigar → corrigir → verificar |

---

## 4. Conclusão

O formato atual documenta **sintomas**. A aviação ensina a documentar **causas, mecanismos, e prevenções**. A diferença é a diferença entre:

- **"O avião caiu"** → formato atual
- **"O avião caiu porque: (1) falha no sensor de pitot → (2) tripulação perdeu consciência de velocidade → (3) procedimento de unreliable airspeed não foi seguido → (4) treinamento não cobria este cenário → PREVENÇÃO: atualizar SOP + treinar em simulador"** → formato aviação

O próximo documento (17) apresenta os templates melhorados que implementam estas correções.
