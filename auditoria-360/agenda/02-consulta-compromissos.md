# Metodologia de Auditoria — Consulta de Compromissos

**Funcionalidade:** `agenda/02-consulta-compromissos`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp → Fix Conflito v2
  → Escolher Branch → buscar_evento_agenda
    → prompt_busca1 (prompt de busca de eventos)
    → AI Agent → Tool: buscar_eventos (httpRequestTool)
      → Calendar WebHooks (webhook "Buscar eventos - Webhook")
        → Monta filtros (data inicio, data fim)
        → GET calendar + GET recorrentes → Expandir Recorrentes (code)
        → Merge → Aggregate → Information Extractor (LLM formata)
        → Retorna lista formatada
    → IA formata agenda pro user
```

### Nós relevantes

| Nó | Workflow | Função |
|----|----------|--------|
| `buscar_eventos` | Fix Conflito v2 | Tool HTTP → Calendar WebHooks |
| `Buscar eventos - Webhook` | Calendar WebHooks | Recebe filtros |
| `Get many rows9` | Calendar WebHooks | SELECT calendar |
| `Get Recorrentes` | Calendar WebHooks | SELECT is_recurring=true |
| `Expandir Recorrentes` | Calendar WebHooks | Code: expande rrule em instâncias |
| `Merge` | Calendar WebHooks | Junta pontuais + recorrentes expandidos |
| `Information Extractor1` | Calendar WebHooks | LLM formata resultado |

### Comportamento

- Busca é **READ-ONLY** — não cria nem modifica nada
- Recorrentes são **expandidos** em instâncias individuais antes de retornar
- Resultado formatado por LLM (Information Extractor) — pode alterar/omitir dados

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  SELECT calendar do user com filtro de data → EVENTOS_REAIS
  1.2  Último log_id → LAST_LOG_ID

PASSO 2 — ENVIAR MENSAGEM ("o que tenho hoje?", "agenda da semana", etc)

PASSO 3 — POLLAR RESPOSTA

PASSO 4 — CRUZAR
  4.1  Extrair eventos da resposta da IA
  4.2  Para cada evento que IA listou:
       → Existe no banco com mesmo nome e data? SIM = correto, NÃO = IA inventou
  4.3  Para cada evento no banco dentro do range:
       → IA listou? SIM = cobriu, NÃO = IA omitiu
  4.4  Calendar count NÃO mudou (busca não cria nada)

PASSO 5 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Resposta contém eventos | IA listou eventos existentes | Vazio indevido |
| 2 | Sem fantasmas | Todos os eventos listados existem no banco | IA inventou evento |
| 3 | Sem omissões | Todos os eventos do range foram listados | IA omitiu evento |
| 4 | Datas corretas | Horários batem com start_event | Horário errado |
| 5 | Nada criado | COUNT_DEPOIS = COUNT_ANTES | Criou algo |
| 6 | Recorrentes expandidos | Eventos recorrentes aparecem nas datas corretas | Não expandiu |

---

## 4. Protocolo de diagnóstico de erros

```
CAMADA 1 — CLASSIFICADOR: Foi pra buscar_evento_agenda?
CAMADA 2 — TOOL: buscar_eventos foi chamada?
CAMADA 3 — FILTROS: Datas de início/fim estão corretas?
CAMADA 4 — QUERY: SELECT retornou os registros esperados?
CAMADA 5 — EXPANSÃO: Recorrentes foram expandidos corretamente?
CAMADA 6 — FORMATAÇÃO: Information Extractor omitiu/alterou dados?
```

---

## 5. Testes

**🟢 Quick (3 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| CON-Q1 | "o que tenho hoje?" | Cruzar com SELECT calendar WHERE date=hoje |
| CON-Q2 | "agenda da semana" | Cruzar com SELECT calendar WHERE date BETWEEN hoje AND +7d |
| CON-Q3 | "o que tenho amanhã?" | Cruzar com SELECT calendar WHERE date=amanhã |

**🟡 Broad (Quick + 5 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| CON-B1 | "e depois de amanhã?" | Multi-turno: contexto temporal |
| CON-B2 | "próximos 5 dias" | Range numérico |
| CON-B3 | "agenda de sexta" | Dia da semana (próxima sexta) |
| CON-B4 | "o que tenho dia 25?" | Data específica |
| CON-B5 | Dia sem eventos | IA diz "sem eventos" e não inventa |

**🔴 Complete (Broad + 4 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| CON-C1 | "agenda do mês" | Range longo — todos os eventos do mês |
| CON-C2 | Recorrentes no range | Eventos recorrentes aparecem expandidos? |
| CON-C3 | "quantos eventos tenho?" | Contagem bate com banco |
| CON-C4 | Range com 20+ eventos | IA lista todos ou trunca? |

---

## 6. Formato do log

```markdown
| ID | Input | Eventos IA | Eventos banco | Fantasmas | Omissões | Veredicto |
```

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Logar filtros usados (data_inicio, data_fim) | Saber se range foi correto |
| Verificar expansão de recorrentes vs banco | Detectar erros no Code node |
