# 18 — Template de Log de Teste v2 (Baseado em Aviação)

> Novo formato para logs de teste, com rastreabilidade completa,
> classificação proativa e aprendizado contínuo.

---

## Template

```markdown
# [TEST-ID] — [OPERATION_NAME]

**Funcionalidade:** [feature/path]
**Data:** [ISO 8601]
**Ambiente:** DEV (http://76.13.172.17:5678)
**Duração total do teste:** [Xs]

---

## Veredicto

### **[PASS / FAIL / PARTIAL / TIMEOUT]**

| Dimensão | Score | Detalhe |
|----------|-------|---------|
| **Compreensão** (0.25) | [0-1] | A IA entendeu a intenção? |
| **Precisão** (0.25) | [0-1] | Resposta/ação factualmente correta? |
| **Completude** (0.15) | [0-1] | Pedido totalmente atendido? |
| **Persistência** (0.20) | [0-1] | Dados salvos corretamente? |
| **Contexto** (0.10) | [0-1] | Considerou histórico da conversa? |
| **Tom** (0.05) | [0-1] | Tom adequado ao contexto? |
| **Score Final** | **[decimal]** | Σ(dimensão × peso) |

### Classificação Rápida (TEM)
- **Ameaças detectadas:** [Lista de condições externas — ex: "Redis TTL curto", "workflow async"]
- **Erros encontrados:** [Lista de erros — ex: "categoria divergente", "N8N timeout"]
- **Estado indesejado:** [Se houve — ex: "dado financeiro com categoria errada"]

---

## O que era esperado
[Comportamento esperado detalhado]

## O que aconteceu
[O que realmente aconteceu, com timing]

### Pontos positivos
- [O que funcionou bem]

### Pontos negativos
- [O que falhou ou foi subótimo]

---

## Cadeia de Rastreabilidade (6 Camadas)

### Mensagem Enviada
```
[Texto exato enviado ao webhook]
```

### L1 — Recepção (Webhook)
- **HTTP Status:** [200/4xx/5xx]
- **Exec ID disparado:** [id]
- **Tempo de resposta webhook:** [Xms]

### L2 — Classificação
- **Branch selecionado:** `[branch_name]`
- **Branch esperado:** `[branch_esperado]`
- **Classificação correta?** ✅/❌

### L3 — Contexto (Redis)
- **Mensagens no contexto:** [N mensagens]
- **Contexto relevante preservado?** ✅/❌/N/A

### L4 — Resposta da IA (CVR)
```
[TEXTO COMPLETO da resposta da IA — NUNCA deixar vazio]
```
- **Tools chamadas:** [lista ou "nenhuma"]
- **JSON de ação:**
```json
{ ... }
```

### L5 — Execução da Ação
- **Tabela afetada:** [spent/calendar/reminder/nenhuma]
- **Operação:** [INSERT/UPDATE/DELETE/SELECT/nenhuma]
- **Resultado:** [sucesso/falha + detalhes]

### L6 — Entrega da Resposta
- **Mensagem entregue ao usuário:** ✅/❌
- **Tempo total (envio → resposta):** [Xs]

---

## Execuções N8N

| Exec ID | Workflow | Status | Duração | Nó de Falha | Erro |
|---------|----------|--------|---------|-------------|------|
| [id] | [nome] | ✅/❌ | [Xs] | [nó ou "—"] | [mensagem ou "—"] |

---

## Estado do Banco

### Snapshots
| Tabela | ANTES | DEPOIS | Δ | Δ Esperado | Match? |
|--------|-------|--------|---|-----------|--------|
| [table] | [n] | [n] | [+/-n] | [+/-n] | ✅/❌ |

### Verificação Campo-a-Campo (quando aplicável)
| Campo | Valor Encontrado | Valor Esperado | Match? |
|-------|-----------------|----------------|--------|
| name_spent | "Mercado" | "Mercado" | ✅ |
| category_spent | "Outros" | "Alimentação" | ❌ |
| ... | ... | ... | ... |

---

## KPIs do Teste

| KPI | Valor | Peso | Descrição |
|-----|-------|------|-----------|
| Funcional | [0/0.5/1] | 0.30 | A funcionalidade fez o que deveria? |
| Banco | [0/0.5/1] | 0.25 | O banco reflete a ação corretamente? |
| N8N | [0/0.5/1] | 0.15 | Workflows executaram sem erro? |
| Consistência | [0/0.5/1] | 0.20 | IA disse a mesma coisa que o banco mostra? |
| Tempo | [0/0.5/1] | 0.10 | Operação completou em tempo aceitável? |
| **Score Ponderado** | **[decimal]** | — | Σ(KPI × Peso) |

---

## Aprendizado (LOSA + Kaizen)

### O que este teste ensina?
> [1-3 frases sobre o que aprendemos com este teste, mesmo se PASS.
> PASS também gera aprendizado — ex: "Operação de criação é consistentemente
> rápida (<5s), indicando que o pipeline CREATE está otimizado."]

### Ameaças observadas (TEM)
> [Condições que PODERIAM ter causado problemas mas não causaram neste teste.
> Ex: "Redis TTL de 5min está perto de expirar durante testes sequenciais rápidos."]

### Recomendações (se FAIL/PARTIAL)

**Correção:**
1. [Ação específica]

**Prevenção:**
1. [Como evitar recorrência]

### Gera erro? [Sim → ERR-NNN / Não]

---

## Método Utilizado

1. Snapshot BEFORE (contagem + estado)
2. POST webhook com mensagem do usuário
3. Poll resposta (loop 45s, check 3s)
4. [Se edit/delete] Wait async 20s
5. Snapshot AFTER (contagem + registro específico)
6. Cross-check: IA response vs banco vs expectativa
7. Classificar e documentar

---

*Teste executado por @auditor (Lupa) — Auditoria 360 v2*
```

---

## Mudanças vs. Template Anterior

| Aspecto | v1 (Atual) | v2 (Aviation) |
|---------|-----------|---------------|
| Veredicto | PASS/FAIL/VERIFY | PASS/FAIL/PARTIAL/TIMEOUT + 6 dimensões |
| Resposta IA | Sempre vazia | OBRIGATÓRIA + branch + tools + JSON |
| Trace | Não existia | 6 camadas completas |
| Classificação | Após o fato (no erro) | Inline no log (TEM: ameaças/erros/estados) |
| DB verification | Contagem antes/depois | Contagem + campo-a-campo |
| N8N errors | "error" sem detalhe | Nó de falha + mensagem completa |
| Aprendizado | Nenhum | Seção obrigatória mesmo em PASS |
| Ameaças | Não capturadas | TEM: ameaças observadas |
| Timing | Não capturado | Duração total + por camada |
| Recomendações | Nenhuma no log | Correção + Prevenção inline |
| Link com erro | Implícito | Explícito: "Gera erro? ERR-NNN" |
