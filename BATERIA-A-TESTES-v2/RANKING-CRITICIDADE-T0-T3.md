# Ranking de Criticidade — T0 a T3
**Data:** 2026-03-17
**Baseado em:** Bateria A v2 (199 testes, 18 warnings)

---

## Escala de Criticidade

| Tier | Descrição | Critério |
|------|-----------|----------|
| **T0** | Crítico — corrigir imediatamente | Dados incorretos, perda de dados, impacta todos os users |
| **T1** | Alto — corrigir essa semana | Funcionalidade quebrada em >40% dos casos |
| **T2** | Médio — corrigir no próximo ciclo | Funcionalidade instável em 20-40% dos casos |
| **T3** | Baixo — backlog | UX ruim mas funcionalidade ok, <20% dos casos |

---

## T0 — CRÍTICO (0 bugs)

**Nenhum bug T0 na Bateria A v2.**

Todos os bugs T0 anteriores foram **corrigidos**:
- ~~Ação vs declaração (pix/boleto registrado como gasto)~~ → CORRIGIDO
- ~~Investimento registrado como gasto~~ → CORRIGIDO
- ~~"Registro registrado" + Cat Outros~~ → CORRIGIDO
- ~~Multi-turno registra gasto fantasma~~ → CORRIGIDO (0 ocorrências em 199 testes)

---

## T1 — ALTO (2 bugs)

### T1-001: Excluir evento após rename falha
- **Frequência:** 4/5 passadas (80%)
- **IDs afetados:** A2.18 (exec:10544), A3.18 (exec:10667), A4.18 (exec:10787), A5.18 (exec:10985)
- **O que acontece:** Após renomear um evento (ex: "dentista" → "consulta odonto" → rename para outro nome), a exclusão pelo novo nome falha com "Não encontrei".
- **Causa raiz:** O workflow `editar-eventos` no Calendar WebHooks pode estar atualizando no Supabase mas não sincronizando o rename no Google Calendar. A busca posterior lê do Google (que tem o nome antigo) e não encontra.
- **Impacto:** Usuário não consegue excluir evento renomeado. Precisa saber o nome original.
- **Onde investigar:** Workflow Calendar WebHooks → node `editar_evento_google3` → verificar se PATCH no Google Calendar está sendo chamado no rename
- **Documentação:** `TESTES-NOVISSIMOS-16-03-2026/BACKLOG-DIAGNOSTICO-PROFUNDO.md` (Bug #9)

### T1-002: Excluir evento recorrente (uma ocorrência) falha
- **Frequência:** 2/5 passadas (40%)
- **IDs afetados:** A1.19 (exec:10425), A5.19 (exec:10988)
- **O que acontece:** "Cancela a academia de segunda" ou "tira o futebol desse sábado" retorna "Não encontrei".
- **Causa raiz:** Eventos recorrentes armazenados com `rrule`. Instâncias individuais podem não ter row no banco. Busca por `start_event` de data específica falha se instância não foi expandida.
- **Impacto:** Usuário não consegue cancelar uma ocorrência específica de evento recorrente.
- **Onde investigar:** Webhook `busca-total-evento` → query no Supabase → considerar `is_recurring` + `rrule`
- **Documentação:** `TESTES-NOVISSIMOS-16-03-2026/02-AGENDA/excluir-recorrente/ANALISE.md`

---

## T2 — MÉDIO (3 bugs)

### T2-001: Excluir último gasto falha quando contexto está sujo
- **Frequência:** 2/5 passadas (40%)
- **IDs afetados:** A1.09 (exec:10391), A2.09 (exec:10517)
- **O que acontece:** "Apaga meu último gasto" retorna "Não encontrei" ou apaga o errado.
- **Causa raiz:** A IA usa o nome do gasto do contexto da conversa (Redis) ao invés de buscar ORDER BY data DESC LIMIT 1 no banco.
- **Impacto:** Confusão sobre qual gasto foi excluído.
- **Onde investigar:** Node `excluir2` → prompt de exclusão → regra de "último"
- **Documentação:** `TESTES-NOVISSIMOS-16-03-2026/BACKLOG-DIAGNOSTICO-PROFUNDO.md` (Bug #15)

### T2-002: Excluir múltiplos gastos retorna "não encontrei" quando banco está vazio
- **Frequência:** 3/5 passadas (60%)
- **IDs afetados:** A1.10 (exec:10398), A2.10 (exec:10520), A3.10 (exec:10644)
- **O que acontece:** "Apaga todos os gastos de uber/gasolina/mercado" → "Não encontrei". Pode ser correto se realmente não há gastos desse tipo (foram excluídos antes nos testes).
- **Causa raiz:** NÃO é necessariamente um bug — pode ser que os testes anteriores na mesma passada já excluíram todos. A resposta poderia ser mais clara: "Não há gastos de uber para excluir" ao invés de "Não encontrei".
- **Impacto:** UX — mensagem confusa quando não há nada para excluir.
- **Documentação:** Novo achado desta bateria.

### T2-003: Cancelar lembrete recorrente vago falha
- **Frequência:** 1/5 passadas (20%)
- **IDs afetados:** A4.26 (exec:10838)
- **O que acontece:** "Tira o do condomínio" → "Não encontrei". O lembrete existe como "Pagar Condomínio" mas a busca por "condomínio" sozinho não encontra.
- **Causa raiz:** Mensagem muito vaga ("o do condomínio") dificulta a busca. Pode ser ILIKE insuficiente ou a IA não monta a busca correta.
- **Onde investigar:** Webhook `busca-total-evento` → query ILIKE
- **Documentação:** `TESTES-NOVISSIMOS-16-03-2026/03-LEMBRETES/cancelar-recorrente/ANALISE.md`

---

## T3 — BAIXO (2 bugs)

### T3-001: Busca por categoria retorna vazio quando realmente não há gastos
- **Frequência:** 2/5 passadas (40%)
- **IDs afetados:** A2.04 (exec:10493), A3.04 (exec:10621)
- **O que acontece:** "Busca gastos de transporte" ou "quanto gastei com moradia" retorna vazio. Pode ser correto se não há gastos nessa categoria no período.
- **Causa raiz:** NÃO é bug — é resultado correto. Mas a mensagem poderia ser mais útil.
- **Impacto:** Nenhum impacto real. Apenas UX da mensagem.

### T3-002: Editar categoria não encontra quando gasto já foi excluído
- **Frequência:** 2/5 passadas (40%)
- **IDs afetados:** A1.07 (exec:10385), A5.07 (exec:10896)
- **O que acontece:** "Muda categoria do restaurante/rodízio pra alimentação" → "Não encontrei". O gasto pode ter sido excluído em um teste anterior.
- **Causa raiz:** Contexto de teste — os testes são sequenciais e um teste pode afetar o próximo.
- **Impacto:** Falso positivo nos testes. Não é bug real.

---

## Resumo Visual

```
T0 (CRÍTICO):   0 bugs  ████████████████████ LIMPO!
T1 (ALTO):      2 bugs  ██░░░░░░░░░░░░░░░░░░
T2 (MÉDIO):     3 bugs  ███░░░░░░░░░░░░░░░░░
T3 (BAIXO):     2 bugs  ██░░░░░░░░░░░░░░░░░░
```

### Comparação com bateria anterior:

| Tier | Antes (200 testes) | Agora (199 testes) | Mudança |
|------|-------------------|-------------------|---------|
| T0 | 4 bugs | **0 bugs** | -4 ✅ |
| T1 | 3 bugs | 2 bugs | -1 ✅ |
| T2 | 5 bugs | 3 bugs | -2 ✅ |
| T3 | 5 bugs | 2 bugs | -3 ✅ |
| **Total** | **17 bugs** | **7 bugs** | **-10 (59% redução)** |

---

## Plano de Ação por Tier

### T1 — Corrigir essa semana:
1. **T1-001 (rename):** Investigar PATCH Google Calendar no workflow editar-eventos. Garantir sync bidirecional.
2. **T1-002 (recorrente):** Adicionar lógica de busca por rrule + data. Expandir instâncias antes de buscar.

### T2 — Corrigir no próximo ciclo:
3. **T2-001 (último gasto):** Reforçar no prompt excluir2: buscar ORDER BY date DESC, não pelo nome do contexto.
4. **T2-002 (excluir vazio):** Melhorar mensagem: "Não há gastos de X para excluir" ao invés de "Não encontrei".
5. **T2-003 (lembrete vago):** Melhorar busca ILIKE no webhook + IA tenta variações.

### T3 — Backlog:
6. **T3-001/T3-002:** Falsos positivos de teste. Não são bugs reais. Ignorar ou ajustar metodologia de teste.
