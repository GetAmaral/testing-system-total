# Stories de Auditoria 360° — Total Assistente

**Data:** 2026-03-18
**Agente:** @testador (Watson)
**Total:** 12 stories | 29 features | 3 níveis de teste

---

## Níveis de teste

| Nível | Nome | Quando usar | Tempo estimado |
|-------|------|-------------|----------------|
| 🟢 | **Quick** | Smoke test — funciona ou não funciona? | 2-5 min |
| 🟡 | **Broad** | Cobertura ampla — testa os cenários principais e edge cases críticos | 10-20 min |
| 🔴 | **Complete** | Auditoria completa — todos os ângulos, todos os campos, todas as verificações | 30-60 min |

---

## Metodologia padrão de cada story

Cada story segue 4 fases:

```
FASE 1 — DIAGNÓSTICO
├── Ler o workflow N8N (nós, branches, prompts)
├── Ler schema das tabelas envolvidas
├── Identificar pontos críticos e caminhos de falha
└── Listar melhorias que facilitariam a auditoria

FASE 2 — DESIGN DOS TESTES
├── Definir testes por nível (quick/broad/complete)
├── Para cada teste: input, output esperado, verificação no banco
├── Ordenar por relevância (o que é mais provável de falhar primeiro)
└── Gerar template de log

FASE 3 — EXECUÇÃO
├── Snapshot ANTES (contagem + estado)
├── Enviar mensagem → Pollar resposta
├── Verificar banco REAL (spent/calendar/etc.)
├── Verificar execução N8N (status, nós executados)
├── Registrar resultado no log

FASE 4 — RELATÓRIO
├── Tabela de resultados (passou/falhou/parcial)
├── Bugs encontrados com evidência
├── Divergências IA vs banco
├── Recomendações de melhoria no workflow
└── Push para GitHub
```

---

## STORY 1 — Financeiro: Despesas e Receitas (CRUD)

**Feature:** `financeiro/01-despesas-receitas`
**Prioridade:** CRÍTICA — é o core do produto
**Workflows:** `Fix Conflito v2` (classificador + AI Agent) → `Financeiro - Total` (CRUD spent)
**Tabela:** `spent`
**Status:** 🔬 A executar

### Diagnóstico previsto
- Workflow `Fix Conflito v2`: nó `Escolher Branch` (classificador LLM) decide a intenção
- Branches: `registrar_gasto`, `buscar_gasto`, `editar_gasto`, `excluir2`
- Cada branch seta prompts e chama o `AI Agent` com tools HTTP
- Tools chamam o workflow `Financeiro - Total` via webhook interno
- `Financeiro - Total`: recebe a ação e opera no Supabase (CRUD na tabela `spent`)

### Testes planejados

**🟢 Quick (5 testes):**
1. Criar gasto → verificar no `spent`
2. Criar receita → verificar no `spent`
3. Buscar gastos do dia → cruzar com `spent`
4. Editar valor → esperar async → verificar
5. Excluir gasto → verificar contagem

**🟡 Broad (15 testes):**
- Quick +
6. Editar nome do gasto
7. Editar categoria
8. Buscar por categoria específica
9. Gíria financeira ("torrei 60 conto", "caiu 500 na conta")
10. Valor com centavos ("gastei 29.90")
11. Sem valor explícito ("almocei no restaurante")
12. Excluir múltiplos ("apaga todos de uber")
13. Excluir último ("remove meu último gasto")
14. Buscar semana passada ("gastos da semana anterior")
15. Multi-turno ("e na anterior?")

**🔴 Complete (25 testes):**
- Broad +
16. Classificação de categoria — verificar se IA diz a mesma que o banco grava
17. `type_spent` — verificar se "variavel/fixo/eventuais" está coerente
18. Ação vs declaração ("paga meu boleto de 200" — deve recusar)
19. Investimento ("aplica 2000 em CDB" — deve recusar)
20. Valor zero ou negativo
21. Nome muito longo (100+ caracteres)
22. Emoji no nome do gasto ("almocei 🍕")
23. Verificar `fk_user` correto em todos os registros
24. Verificar `date_spent` = dia do envio
25. Verificar que edição não cria registro duplicado (contagem antes/depois)

### Verificações por campo (`spent`)
| Campo | Verificar |
|-------|-----------|
| `name_spent` | Match com IA |
| `value_spent` | Match com IA |
| `category_spent` | Match com IA ⚠️ divergência conhecida |
| `transaction_type` | saida/entrada correto |
| `type_spent` | Classificação coerente |
| `date_spent` | Data do dia |
| `created_at` | ±5s da mensagem |
| `fk_user` | User de teste correto |

### Melhorias sugeridas para o workflow
- `Financeiro - Total`: logar `id_spent` do registro criado/editado/deletado no `log_total`
- `Escolher Branch`: logar qual branch escolheu (para diagnosticar classificação errada)

---

## STORY 2 — Agenda: CRUD de Eventos

**Feature:** `agenda/01-agendamento-proprio` + `03-modificacao` + `04-exclusao`
**Prioridade:** CRÍTICA
**Workflows:** `Fix Conflito v2` → `Calendar WebHooks`
**Tabela:** `calendar`
**Status:** 🔬 A executar

### Diagnóstico previsto
- `Fix Conflito v2`: branches `prompt_criar1`, `prompt_editar1`, `prompt_excluir`
- Tools: `buscar_eventos`, `editar_eventos`, `excluir_evento`
- Tools chamam `Calendar WebHooks` via webhook
- `Calendar WebHooks`: CRUD no Supabase `calendar` + sync Google Calendar
- Edição e exclusão são ASYNC (IA responde antes do banco atualizar)

### Testes planejados

**🟢 Quick (5 testes):**
1. Criar evento pontual → verificar no `calendar`
2. Consultar agenda do dia → cruzar com `calendar`
3. Editar data do evento → esperar async → verificar
4. Excluir evento → verificar remoção
5. Criar lembrete sem horário → verificar horário padrão

**🟡 Broad (15 testes):**
- Quick +
6. Editar horário
7. Renomear evento → verificar que NÃO deleta ⚠️ bug Bateria 04
8. Excluir por nome parcial
9. Consultar semana
10. Consultar "próximos 5 dias"
11. Evento com data implícita ("amanhã", "sexta")
12. Evento com data explícita ("dia 25 de março")
13. `end_event` correto após edição de data ⚠️ bug confirmado
14. `compromisso_tipo` correto (compromisso vs lembrete)
15. `connect_google` + `session_event_id_google` preenchidos

**🔴 Complete (20 testes):**
- Broad +
16. Conflito de horário (dois eventos no mesmo horário)
17. Evento no passado
18. Evento com duração explícita ("reunião de 2h")
19. Excluir múltiplos ("apaga tudo de sexta")
20. `timezone` = America/Sao_Paulo

### Melhorias sugeridas
- `Calendar WebHooks`: ao editar `start_event`, recalcular `end_event`
- Logar ação no `log_total` com `id` do evento criado/editado/excluído

---

## STORY 3 — Agenda: Lembretes Recorrentes

**Feature:** `agenda/06-lembretes-recorrentes`
**Prioridade:** ALTA — bugs conhecidos de duplicação
**Workflows:** `Lembretes Total Assistente` + `Fix Conflito v2`
**Tabela:** `calendar` (is_recurring=true, rrule)
**Status:** 🔬 A executar

### Testes planejados

**🟢 Quick (3 testes):**
1. Criar recorrente semanal → verificar `is_recurring` e `rrule`
2. Criar recorrente mensal → verificar `rrule`
3. Cancelar recorrente → verificar remoção

**🟡 Broad (10 testes):**
- Quick +
4. Múltiplos dias ("terça e quinta")
5. Duplicação: criar mesmo recorrente 2x → contar registros
6. `next_fire_at` calculado corretamente
7. Excluir uma ocorrência específica
8. `exdates` preenchido ao excluir ocorrência
9. Recorrente com Google Calendar sync
10. Lembrete automático dispara? (verificar `remembered`)

**🔴 Complete (15 testes):**
- Broad +
11-15. Edge cases de rrule, fuso horário, recorrentes no fim do mês

### Melhorias sugeridas
- Verificar se `Expandir Recorrentes` (Code node) gera instâncias corretas
- Logar `next_fire_at` calculado

---

## STORY 4 — Bot WhatsApp: Classificador e Roteamento

**Feature:** `bot-whatsapp/01-roteador-principal` + `02-fluxo-premium`
**Prioridade:** ALTA — é o cérebro do sistema
**Workflows:** `Main - Total Assistente` + `Fix Conflito v2` (nó `Escolher Branch`)
**Status:** 🔬 A executar

### Diagnóstico previsto
- `Main`: recebe webhook, verifica user, switch por tipo de plano
- Se Premium → chama `Fix Conflito v2` via webhook
- `Fix Conflito v2`: `Escolher Branch` (LLM) classifica intenção
- Branches: registrar_gasto, buscar_gasto, editar_gasto, excluir, criar_compromisso, editar_eventos, excluir_evento, lembrete, padrao, relatorio

### Testes planejados

**🟢 Quick (5 testes):**
1. Mensagem de gasto → verificar que foi pra branch financeiro
2. Mensagem de agenda → verificar que foi pra branch agenda
3. Saudação → verificar branch "padrao"
4. Fora do escopo → verificar que não criou nada
5. Ação financeira ("paga meu boleto") → verificar que NÃO registrou

**🟡 Broad (15 testes):**
- Quick +
6-10. Gírias, typos, emojis, mensagens ambíguas
11-15. Verificar via N8N API qual branch foi escolhida em cada execução

**🔴 Complete (20 testes):**
- Broad + contexto multi-turno, audio, imagem

### Melhorias sugeridas
- `Escolher Branch`: logar decisão (qual branch + confiança) no `log_total`

---

## STORY 5 — Agenda: Consulta de Compromissos

**Feature:** `agenda/02-consulta-compromissos`
**Prioridade:** MÉDIA
**Tabela:** `calendar` (SELECT)
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (3):** Agenda dia, semana, data específica
**🟡 Broad (8):** Multi-turno, "e amanhã?", eventos recorrentes expandidos, filtro por tipo
**🔴 Complete (12):** Todos os formatos de data, limites de range, agenda vazia

---

## STORY 6 — Financeiro: Limites e Metas

**Feature:** `financeiro/02-limites-categoria` + `03-metas-financeiras` + `04-limite-mensal`
**Prioridade:** MÉDIA
**Tabela:** `category_limits` + lógica no workflow
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (3):** Definir limite, ultrapassar, verificar alerta
**🟡 Broad (8):** Múltiplas categorias, reset mensal, meta parcial
**🔴 Complete (12):** Edge cases de cálculo, mês incompleto, múltiplos users

---

## STORY 7 — Relatórios (PDF + WhatsApp)

**Feature:** `relatorios/01-relatorio-pdf-whatsapp`
**Prioridade:** MÉDIA
**Workflow:** `Report Unificado - Total Assistente`
**Tabela:** `reports` + Gotenberg (PDF)
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** Relatório mensal, relatório semanal
**🟡 Broad (6):** Período custom, relatório com dados zero, verificar `reports` table
**🔴 Complete (10):** PDF gerado correto, dados do PDF batem com `spent`

---

## STORY 8 — Bot WhatsApp: Mídia (Áudio + Imagem)

**Feature:** `bot-whatsapp/04-transcricao-audio` + `05-ocr-imagem-pdf`
**Prioridade:** MÉDIA
**Workflow:** `Main` (Download File, Transcribe) + `Fix Conflito v2` (PDF Extractor)
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** Enviar áudio, enviar imagem
**🟡 Broad (6):** Áudio longo, imagem com texto financeiro, PDF
**🔴 Complete (10):** Qualidade de transcrição, OCR com valores financeiros → verificar no `spent`

---

## STORY 9 — Bot WhatsApp: Bot Guard

**Feature:** `bot-whatsapp/06-bot-guard`
**Prioridade:** BAIXA
**Tabela:** `bot_blocks`, `bot_events`
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** Spam rápido, verificar bloqueio
**🟡 Broad (5):** Rate limit, desbloqueio, loop detection
**🔴 Complete (8):** Thresholds exatos, múltiplos users simultâneos

---

## STORY 10 — Agenda: VIP Calendar + Agenda Diária

**Feature:** `agenda/07-agenda-diaria-automatica` + `08-vip-calendar`
**Prioridade:** BAIXA
**Tabela:** `calendar_vip`
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** VIP calendar por telefone, agenda automática dispara
**🟡 Broad (5):** Horário configurável, apenas Premium
**🔴 Complete (8):** Isolamento VIP vs regular

---

## STORY 11 — Autenticação

**Feature:** `autenticacao/01-login-otp` a `05-gestao-conta`
**Prioridade:** BAIXA (para Watson — testável apenas parcialmente via WhatsApp)
**Workflow:** `Main` (nós de OTP, Switch stg4)
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** Onboarding flow via WhatsApp, RBAC Premium vs Standard
**🟡 Broad (5):** OTP inválido, plano expirado, conta inativa
**🔴 Complete (8):** 2FA, Google OAuth, gestão de conta

### Nota
Autenticação via frontend (OTP, OAuth) está fora do escopo direto de Watson. Testaremos apenas os fluxos que passam pelo WhatsApp.

---

## STORY 12 — Pagamentos e Investimentos

**Feature:** `pagamentos/*` + `investimentos/01-portfolio`
**Prioridade:** BAIXA (para Watson)
**Tabela:** `payments`, `subscriptions`, `investments`
**Status:** 🔬 A executar

### Testes planejados
**🟢 Quick (2):** Verificar tabelas, simular webhook Hotmart
**🟡 Broad (5):** Ciclo compra → ativação → cancelamento
**🔴 Complete (8):** Short links, reativação, investimentos (tabela existe mas sem workflow)

---

## Ordem de execução recomendada

```
PRIORIDADE CRÍTICA (executar primeiro):
  Story 1 → Financeiro CRUD          (core do produto, mais bugs)
  Story 2 → Agenda CRUD              (segundo core, async bugs)

PRIORIDADE ALTA:
  Story 3 → Lembretes Recorrentes    (bugs de duplicação)
  Story 4 → Classificador/Roteamento (cérebro do sistema)

PRIORIDADE MÉDIA:
  Story 5 → Consulta de Compromissos
  Story 6 → Limites e Metas
  Story 7 → Relatórios PDF
  Story 8 → Mídia (Áudio/Imagem)

PRIORIDADE BAIXA:
  Story 9  → Bot Guard
  Story 10 → VIP Calendar
  Story 11 → Autenticação
  Story 12 → Pagamentos/Investimentos
```

---

## Recomendações globais de melhoria no workflow

Estas melhorias tornam a auditoria mais barata e precisa. **Não bloqueiam a execução das stories** — farei os testes com ou sem elas.

| # | Melhoria | Onde | Impacto |
|---|----------|------|---------|
| 1 | **Audit triggers** (SQL pronto no plano de ação) | Supabase | Verificação de edições/exclusões |
| 2 | **`Escolher Branch` logar decisão** no `log_total` | Fix Conflito v2 | Saber qual branch foi escolhida |
| 3 | **`Financeiro - Total` logar `id_spent`** no `log_total` | Financeiro | Rastreio direto sem busca por nome |
| 4 | **`Calendar WebHooks` recalcular `end_event`** ao mover | Calendar WH | Corrige bug confirmado |
| 5 | **`Calendar WebHooks` logar `id` do evento** no `log_total` | Calendar WH | Rastreio direto |
| 6 | **Alinhar categorias** entre prompt da IA e banco | Fix Conflito v2 | Resolve divergência "Renda Extra" vs "Outros" |

---

*Stories criadas por @testador (Watson) — Pronto para executar. Qual story primeiro?*
