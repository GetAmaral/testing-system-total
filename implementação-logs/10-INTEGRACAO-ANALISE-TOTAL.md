# Integração com o Sistema analise-total

**Data:** 2026-03-18
**Objetivo:** Exibir dados do execution_log no painel analise-total, filtrado por usuário

---

## Arquitetura Atual do analise-total

O `analise-total` é uma SPA React que conecta em **2 Supabase**:

| DB | Ref | Uso |
|----|-----|-----|
| DB1 | hkzgttizcfklxfafkzfl | `log_users_messages`, `log_total`, dashboard RPC functions |
| DB2 | ldbdtakddxznfridsarn | `profiles`, `subscriptions`, `google_calendar_connections` |

**Views existentes:**
1. Chat Total (simulador WhatsApp)
2. User Log (histórico de mensagens)
3. Manage Users (CRUD)
4. Dashboard (KPIs e gráficos)
5. Documentation (GitHub viewer)

---

## Onde colocar o execution_log?

### Opção escolhida: DB2 (ldbdtakddxznfridsarn)

**Por quê:**
- É onde o N8N já tem credencial Supabase configurada
- É onde o workflow de log centralizado escreverá
- O analise-total já conecta nesse DB para profiles/subscriptions
- Não precisa criar nova credencial no N8N

O `app.js` já tem `supabaseDB2` configurado — basta adicionar queries para `execution_log`.

---

## Nova View: "Execution Log" (Audit Trail)

### Localização no menu

Adicionar como 6ª opção no menu principal:

```
[Chat Total] [User Log] [Manage Users] [Dashboard] [Execution Log] [Documentation]
```

### Layout da view

```
┌─────────────────────────────────────────────────────────────────┐
│ 🔍 Execution Log — Audit Trail                                 │
├─────────────┬───────────────────────────────────────────────────┤
│             │                                                   │
│  FILTROS    │  TIMELINE DE EVENTOS                              │
│             │                                                   │
│  Usuário:   │  ┌─ 14:02:03 ─────────────────────────────────┐  │
│  [________] │  │ 📩 message_routed                           │  │
│             │  │ "Gastei 50 no almoço" → premium             │  │
│  Período:   │  └─────────────────────────────────────────────┘  │
│  [7d][30d]  │                                                   │
│  [custom]   │  ┌─ 14:02:04 ─────────────────────────────────┐  │
│             │  │ 🏷️ classification                           │  │
│  Tipo:      │  │ branch: criar_gasto                         │  │
│  ☑ all      │  └─────────────────────────────────────────────┘  │
│  ☐ actions  │                                                   │
│  ☐ errors   │  ┌─ 14:02:05 ─────────────────────────────────┐  │
│  ☐ ai       │  │ 🤖 ai_response                             │  │
│             │  │ ação: registrar_gasto                        │  │
│  Workflow:  │  │ tools: [registrar_financeiros]               │  │
│  ☑ all      │  │ "Registrei R$50 em Alimentação"             │  │
│  ☐ main     │  └─────────────────────────────────────────────┘  │
│  ☐ premium  │                                                   │
│  ☐ standard │  ┌─ 14:02:06 ─────────────────────────────────┐  │
│  ☐ financ.  │  │ ✅ action_executed                          │  │
│  ☐ calendar │  │ registrar_financeiro → SUCCESS               │  │
│  ☐ report   │  │ {nome:"almoço", valor:50, cat:"Alimentação"}│  │
│             │  └─────────────────────────────────────────────┘  │
│  STATS:     │                                                   │
│  Total: 142 │  ┌─ 14:02:07 ─────────────────────────────────┐  │
│  Erros: 3   │  │ 📋 interaction_complete                     │  │
│  Ações: 45  │  │ Score geral: ✅ OK                          │  │
│             │  └─────────────────────────────────────────────┘  │
│             │                                                   │
└─────────────┴───────────────────────────────────────────────────┘
```

### Componente React

```javascript
// Novo componente a adicionar em app.js
function ExecutionLogView() {
  const [logs, setLogs] = React.useState([]);
  const [filters, setFilters] = React.useState({
    userPhone: '',
    period: '7d',
    eventType: 'all',
    sourceWorkflow: 'all'
  });
  const [stats, setStats] = React.useState({});
  const [loading, setLoading] = React.useState(false);

  // Buscar logs filtrados
  async function fetchLogs() {
    setLoading(true);
    let query = supabaseDB2
      .from('execution_log')
      .select('*')
      .order('created_at', { ascending: false })
      .limit(500);

    // Filtro por usuário (phone ou nome)
    if (filters.userPhone) {
      const input = filters.userPhone.trim();
      // Se parece com telefone (só números)
      if (/^\d+$/.test(input)) {
        query = query.eq('user_phone', input);
      } else {
        // Buscar por nome
        query = query.ilike('user_name', `%${input}%`);
      }
    }

    // Filtro por período
    const now = new Date();
    let startDate;
    switch (filters.period) {
      case '7d': startDate = new Date(now - 7 * 86400000); break;
      case '30d': startDate = new Date(now - 30 * 86400000); break;
      case '90d': startDate = new Date(now - 90 * 86400000); break;
      default: startDate = null;
    }
    if (startDate) {
      query = query.gte('created_at', startDate.toISOString());
    }

    // Filtro por event_type
    if (filters.eventType !== 'all') {
      query = query.eq('event_type', filters.eventType);
    }

    // Filtro por workflow
    if (filters.sourceWorkflow !== 'all') {
      query = query.eq('source_workflow', filters.sourceWorkflow);
    }

    const { data, error } = await query;
    if (!error) {
      setLogs(data);
      // Calcular stats
      setStats({
        total: data.length,
        errors: data.filter(l => l.error_message).length,
        actions: data.filter(l => l.event_type === 'action_executed').length,
        interactions: data.filter(l => l.event_type === 'interaction_complete').length
      });
    }
    setLoading(false);
  }

  React.useEffect(() => { fetchLogs(); }, [filters]);

  // Renderizar event card com cor por tipo
  function getEventColor(eventType) {
    const colors = {
      'message_routed': '#3b82f6',      // azul
      'classification': '#8b5cf6',       // roxo
      'ai_response': '#06b6d4',          // ciano
      'action_executed': '#22c55e',      // verde
      'interaction_complete': '#6b7280', // cinza
      'transcription': '#f59e0b',        // amarelo
      'audio_summary': '#f59e0b',        // amarelo
      'whatsapp_sent': '#25d366',        // verde whatsapp
      'error': '#ef4444',                // vermelho
      'button_action': '#ec4899'         // rosa
    };
    return colors[eventType] || '#6b7280';
  }

  function getEventIcon(eventType) {
    const icons = {
      'message_routed': '📩',
      'classification': '🏷️',
      'ai_response': '🤖',
      'action_executed': '✅',
      'interaction_complete': '📋',
      'transcription': '🎤',
      'audio_summary': '📝',
      'whatsapp_sent': '💬',
      'error': '❌',
      'button_action': '🔘',
      'reminder_fired': '⏰',
      'report_generated': '📊',
      'google_calendar_sync': '📅'
    };
    return icons[eventType] || '📌';
  }

  // ... render JSX com filtros sidebar + timeline de eventos
}
```

### Queries Supabase

```javascript
// 1. Buscar todos os logs de um usuário (por telefone)
const { data } = await supabaseDB2
  .from('execution_log')
  .select('*')
  .eq('user_phone', phone)
  .order('created_at', { ascending: true });

// 2. Buscar por user_id
const { data } = await supabaseDB2
  .from('execution_log')
  .select('*')
  .eq('user_id', userId)
  .order('created_at', { ascending: true });

// 3. Buscar apenas erros
const { data } = await supabaseDB2
  .from('execution_log')
  .select('*')
  .eq('user_phone', phone)
  .not('error_message', 'is', null)
  .order('created_at', { ascending: false });

// 4. Buscar ações destrutivas (DELETEs)
const { data } = await supabaseDB2
  .from('execution_log')
  .select('*')
  .like('action_type', 'excluir%')
  .order('created_at', { ascending: false });

// 5. Timeline completa de uma interação
const { data } = await supabaseDB2
  .from('execution_log')
  .select('*')
  .eq('user_phone', phone)
  .gte('created_at', startDate)
  .lte('created_at', endDate)
  .order('created_at', { ascending: true });

// 6. Stats para dashboard
const { data } = await supabaseDB2
  .from('execution_log')
  .select('event_type, source_workflow, action_success, error_message')
  .gte('created_at', startDate);
```

---

## Dashboard: Novos KPIs do Execution Log

### Cards de métricas a adicionar:

```
┌──────────────┐ ┌──────────────┐ ┌──────────────┐ ┌──────────────┐
│ Execuções    │ │ Taxa Sucesso │ │ Erros 24h    │ │ Ações Destr. │
│   1.247      │ │   97.3%      │ │     3         │ │     12       │
│   últimos 7d │ │              │ │   ⚠️ atenção  │ │   DELETEs    │
└──────────────┘ └──────────────┘ └──────────────┘ └──────────────┘
```

### Gráficos a adicionar:

1. **Line Chart:** Volume de execuções por dia (últimos 30d)
2. **Doughnut:** Distribuição por event_type
3. **Bar Chart:** Erros por workflow
4. **Heatmap:** Atividade por hora do dia

### Queries para KPIs:

```sql
-- RPC function para dashboard de execuções
CREATE OR REPLACE FUNCTION fn_execution_log_resumo(
  p_start_date TIMESTAMPTZ,
  p_end_date TIMESTAMPTZ
)
RETURNS JSON AS $$
DECLARE
  result JSON;
BEGIN
  SELECT json_build_object(
    'total_executions', COUNT(*),
    'total_errors', COUNT(*) FILTER (WHERE error_message IS NOT NULL),
    'total_actions', COUNT(*) FILTER (WHERE event_type = 'action_executed'),
    'total_interactions', COUNT(*) FILTER (WHERE event_type = 'interaction_complete'),
    'total_deletes', COUNT(*) FILTER (WHERE action_type LIKE 'excluir%'),
    'success_rate', ROUND(
      100.0 * COUNT(*) FILTER (WHERE action_success = true OR action_success IS NULL)
      / NULLIF(COUNT(*), 0), 1
    ),
    'unique_users', COUNT(DISTINCT user_phone),
    'by_workflow', (
      SELECT json_object_agg(source_workflow, cnt)
      FROM (
        SELECT source_workflow, COUNT(*) as cnt
        FROM execution_log
        WHERE created_at BETWEEN p_start_date AND p_end_date
        GROUP BY source_workflow
      ) sub
    ),
    'by_event_type', (
      SELECT json_object_agg(event_type, cnt)
      FROM (
        SELECT event_type, COUNT(*) as cnt
        FROM execution_log
        WHERE created_at BETWEEN p_start_date AND p_end_date
        GROUP BY event_type
      ) sub
    )
  ) INTO result
  FROM execution_log
  WHERE created_at BETWEEN p_start_date AND p_end_date;

  RETURN result;
END;
$$ LANGUAGE plpgsql;
```

---

## Passo a Passo de Integração

### Fase 1: Backend (Supabase)
1. Criar tabela `execution_log` em DB2 (migration SQL)
2. Criar trigger de imutabilidade
3. Criar RPC function `fn_execution_log_resumo`
4. Testar queries

### Fase 2: Frontend (app.js)
1. Adicionar "Execution Log" ao menu
2. Criar componente `ExecutionLogView`
3. Implementar filtros (user, período, tipo, workflow)
4. Implementar timeline visual colorida
5. Adicionar KPIs ao Dashboard existente

### Fase 3: Testes
1. Enviar mensagem de teste → verificar log aparece na view
2. Filtrar por usuário → verificar isolamento
3. Filtrar por período → verificar range
4. Verificar que ações destrutivas aparecem destacadas
5. Verificar KPIs calculando corretamente

---

## Observações de Segurança

### Problema atual: Service Role Key exposta no frontend

O `app.js` do analise-total usa a **service_role key** do DB2 diretamente no frontend:
```javascript
// app.js:42 — SECURITY RISK
const supabaseDB2 = createClient(DB2_URL, SERVICE_ROLE_KEY);
```

**Para o execution_log:** Como a tabela tem RLS bloqueando acesso público e só service_role pode ler, a key já exposta funcionará. Mas isso é um risco de segurança geral que deveria ser endereçado separadamente.

**Recomendação futura:** Migrar para uma Edge Function que faz as queries e retorna os dados, em vez de expor a service_role key no frontend.
