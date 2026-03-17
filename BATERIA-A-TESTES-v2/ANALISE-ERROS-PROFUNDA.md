# Análise Profunda dos Erros — Bateria A v2
**Data:** 2026-03-17
**Total de warnings:** 18 (de 199 testes)
**Método:** Análise por execution ID no n8n + cruzamento com workflows

---

## 6 Categorias de Erro Identificadas

### CATEGORIA 1: Excluir múltiplos que não existem (4 erros)
**IDs:** A1.10 (exec:10398), A2.10 (exec:10520), A3.10 (exec:10644), A4.10 (exec:10763)

| Teste | Mensagem | O que buscou |
|-------|----------|-------------|
| A1.10 | "apaga todos os gastos de uber" | Gastos com nome "uber" |
| A2.10 | "remove todos os gastos de gasolina" | Gastos com nome "gasolina" |
| A3.10 | "deleta tudo de mercado" | Gastos com nome "mercado" |
| A4.10 | "apaga tudo que tem de luz" | Gastos com nome "luz" |

**Diagnóstico:** Esses itens nunca foram criados nesta passada de teste, ou foram excluídos em testes anteriores da mesma passada. A busca no banco retorna vazio porque realmente não há registros.

**Causa raiz:** Design do teste — os testes são sequenciais e acumulativos. Se um teste anterior já excluiu todos os registros de uma categoria, o próximo não encontra nada.

**Prioridade:** T3 (falso positivo de teste, não bug real)

**Fix:** Ajustar metodologia de teste para criar dados frescos antes de cada exclusão.

---

### CATEGORIA 2: Excluir evento após rename falha (4 erros)
**IDs:** A2.18 (exec:10544), A3.18 (exec:10667), A4.18 (exec:10787), A5.18 (exec:10985)

| Teste | Nome original | Renomeado para | Tentou excluir |
|-------|-------------|----------------|---------------|
| A2.18 | Reunião com Chefe | Alinhamento Semanal | Alinhamento Semanal |
| A3.18 | Ir no Banco | Resolver Pendências | Resolver Pendências |
| A4.18 | Consulta Médica | Check-Up | Check-Up |
| A5.18 | Oculista | Oftalmologista | Oftalmologista |

**Diagnóstico:** No passo .17 (renomear), a IA confirma sucesso. No passo .18 (excluir pelo novo nome), retorna "Não encontrei".

**Causa raiz identificada no workflow:**

O workflow `editar-eventos` (Calendar WebHooks) faz:
1. `Information Extractor` identifica qual evento editar
2. `Edit Fields5` monta os novos campos
3. `Update a row1` faz UPDATE no Supabase
4. Se Google conectado: `editar_evento_google3` faz PATCH no Google Calendar

O problema está no passo 4: o PATCH no Google Calendar pode estar falhando silenciosamente ou não sendo acionado quando só o nome muda. O Supabase é atualizado, mas a consulta de agenda pode estar lendo do Google Calendar (que mantém o nome antigo).

Alternativamente: o `Update a row1` atualiza TODOS os 4 campos (nome, desc, início, fim). Se os campos de data vêm vazios no rename, podem sobrescrever com vazio → evento fica sem data → desaparece das buscas.

**Node específico:** `Update a row1` no workflow Calendar WebHooks + `editar_evento_google3`

**Prioridade:** T1 (funcionalidade quebrada em 80% dos casos de rename)

**Fix:**
1. Verificar se `editar_evento_google3` roda quando só muda o nome
2. Fazer UPDATE parcial (só campos que mudaram) ao invés de UPDATE total
3. Garantir que campos vazios NÃO sobrescrevem valores existentes

---

### CATEGORIA 3: Excluir/cancelar evento recorrente (3 erros)
**IDs:** A1.19 (exec:10425), A4.26 (exec:10838), A5.19 (exec:10988)

| Teste | Mensagem | Evento recorrente |
|-------|----------|------------------|
| A1.19 | "cancela academia de segunda" | Academia seg/qua/sex |
| A4.26 | "tira o do condomínio" | Pagar Condomínio mensal |
| A5.19 | "tira futebol desse sábado" | Futebol todo sábado |

**Diagnóstico:** Eventos recorrentes são armazenados como 1 registro base com campo `rrule`. Instâncias individuais (ex: "academia de segunda próxima") podem não ter row separada no banco.

A busca via `buscar_eventos` filtra por `start_event` de uma data específica. Se a instância daquela data não foi expandida como row, a busca retorna vazio.

**Node específico:** Webhook `busca-total-evento` → query Supabase

**Prioridade:** T1 (40% de falha em cancelar recorrente + 20% em lembrete recorrente)

**Fix:**
1. Na busca, além de `start_event`, considerar registros com `is_recurring = true` cujo `event_name` bate
2. Ou: expandir instâncias das próximas 2 semanas ao criar o recorrente
3. Para cancelar: criar `exdate` ao invés de deletar o registro base

---

### CATEGORIA 4: Editar categoria após rename (2 erros)
**IDs:** A1.07 (exec:10385), A5.07 (exec:10896)

| Teste | Passo anterior | Passo que falhou |
|-------|---------------|-----------------|
| A1.07 | .06 renomeou "Almoço" → "Restaurante" | .07 "muda categoria do restaurante" |
| A5.07 | .06 renomeou "Janta" → "Rodízio" | .07 "muda rodízio pra lazer" |

**Diagnóstico:** Após renomear no .06, o .07 tenta editar pela novo nome. A busca pode estar usando o nome antigo do contexto Redis ou o rename do .06 não persistiu corretamente.

Mesma causa raiz da Categoria 2 mas para gastos financeiros.

**Node específico:** AI Agent → tool `editar_financeiro` → webhook `/editar-supabase`

**Prioridade:** T2 (40% de falha, mas só quando imediatamente após rename)

**Fix:** Garantir que o rename do .06 é commitado no banco antes do .07 executar. O Redis Chat Memory pode ter o nome antigo cached.

---

### CATEGORIA 5: Excluir último usa histórico ao invés do banco (2 erros)
**IDs:** A1.09 (exec:10391), A2.09 (exec:10517)

| Teste | Contexto anterior | O que tentou excluir |
|-------|-------------------|---------------------|
| A1.09 | .08 excluiu "Restaurante" | Tentou excluir "Restaurante" de novo |
| A2.09 | .08 excluiu "Delivery" | Tentou excluir "Delivery" de novo |

**Diagnóstico:** O prompt `excluir2` tem a regra:
```
REFERÊNCIAS: "último"/"mais recente" = data_gasto mais recente
```

Mas a IA está usando o nome do último gasto da **conversa** (Redis Chat Memory) ao invés de fazer busca no banco por data mais recente. Como o gasto anterior já foi excluído no .08, busca por esse nome e não encontra.

**Node específico:** AI Agent + Redis Chat Memory + prompt `excluir2`

**Prioridade:** T2 (40% de falha, mas corrigível com prompt)

**Fix:** Já incluído no `PROMPT-CORRIGIDO-EXCLUIR2.md`:
```
"Último gasto" = buscar com data_gasto mais recente (ORDER BY data_gasto DESC LIMIT 1).
NUNCA usar nome do gasto anterior da conversa.
```

---

### CATEGORIA 6: Busca retorna vazio (dados realmente não existem) (3 erros)
**IDs:** A2.04 (exec:10493), A3.04 (exec:10621), A4.24 (exec:10830)

| Teste | Mensagem | Motivo do vazio |
|-------|----------|----------------|
| A2.04 | "busca gastos de transporte" | Nenhum gasto de transporte criado nesta passada |
| A3.04 | "quanto gastei com moradia?" | Nenhum gasto de moradia criado nesta passada |
| A4.24 | "meus lembretes da semana" | Nenhum lembrete ativo na semana (excluídos antes) |

**Diagnóstico:** Comportamento CORRETO. A busca retornou vazio porque realmente não há dados. Não é bug.

**Prioridade:** T3 (falso positivo — design do teste)

**Fix:** Nenhum necessário. Ajustar metodologia de teste para criar dados antes de buscar.

---

## Resumo por Categoria

| Cat | Descrição | Erros | Prioridade | Bug real? |
|-----|-----------|-------|-----------|-----------|
| 1 | Excluir múltiplos inexistentes | 4 | T3 | ❌ Teste |
| 2 | Excluir após rename | 4 | T1 | ✅ Bug |
| 3 | Excluir recorrente | 3 | T1 | ✅ Bug |
| 4 | Editar após rename | 2 | T2 | ✅ Bug |
| 5 | Excluir último (contexto) | 2 | T2 | ✅ Bug |
| 6 | Busca vazia (correto) | 3 | T3 | ❌ Teste |

**Bugs reais: 11 de 18 (61%)**
**Falsos positivos de teste: 7 de 18 (39%)**

### Se descontarmos os falsos positivos:
- 199 testes - 7 falsos positivos = 192 testes válidos
- 192 - 11 bugs reais = 181 sucessos
- **Taxa real: 94.3%**
