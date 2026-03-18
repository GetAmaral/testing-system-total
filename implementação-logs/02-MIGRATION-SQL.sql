-- ============================================================
-- MIGRATION: Criar tabela execution_log
-- Data: 2026-03-18
-- Objetivo: Capturar 100% das interações para auditoria
-- ============================================================

-- 1. Criar tabela principal
CREATE TABLE IF NOT EXISTS public.execution_log (
    -- Identificação
    id              UUID DEFAULT gen_random_uuid() PRIMARY KEY,

    -- Usuário
    user_id         TEXT,                    -- UUID do auth.users (ou ONBOARDING-{phone})
    user_phone      TEXT NOT NULL,           -- Telefone WhatsApp (wa_id)
    user_name       TEXT,                    -- Nome do usuário
    user_email      TEXT,                    -- Email do usuário
    user_plan       TEXT,                    -- 'premium' | 'standard' | 'onboarding'

    -- Mensagem do usuário
    user_message    TEXT,                    -- Texto original da mensagem
    message_type    TEXT DEFAULT 'text',     -- 'text' | 'audio' | 'image' | 'document' | 'button' | 'sticker'
    message_id      TEXT,                    -- ID da mensagem no WhatsApp (wamid)

    -- Transcrição (se áudio)
    transcription_text TEXT,                 -- Texto transcrito pelo Whisper
    summary_text    TEXT,                    -- Resumo gerado pelo GPT (se solicitado)

    -- Classificação
    branch          TEXT,                    -- Resultado do "Escolher Branch": criar_gasto, buscar_gasto, etc.

    -- Resposta da IA
    ai_message      TEXT,                    -- Texto da resposta enviada ao usuário
    ai_action       TEXT,                    -- Campo 'acao' do JSON do AI Agent
    ai_tools_called JSONB,                   -- Campo 'tool' do JSON do AI Agent (array de tools)
    ai_full_response JSONB,                  -- JSON completo do AI Agent (acao + mensagem + tool)

    -- Ação executada
    action_type     TEXT,                    -- 'registrar_financeiro' | 'criar_evento' | 'excluir_financeiro' | etc.
    action_input    JSONB,                   -- Dados enviados ao webhook de ação
    action_output   JSONB,                   -- Resposta do webhook de ação
    action_success  BOOLEAN,                 -- Se a ação foi executada com sucesso

    -- Extração de documento (PDF/imagem)
    extracted_data  JSONB,                   -- Dados extraídos de PDF ou imagem

    -- Contexto
    source_workflow TEXT NOT NULL,           -- 'main' | 'premium' | 'standard' | 'financeiro' | 'calendar' | 'lembretes' | 'report'
    event_type      TEXT NOT NULL,           -- 'transcription' | 'audio_summary' | 'message_routed' | 'classification' | 'ai_response' | 'action_executed' | 'interaction_complete'
    routed_to       TEXT,                    -- 'premium' | 'standard' (quando event_type = 'message_routed')

    -- Metadados
    execution_id    TEXT,                    -- ID da execução no N8N (se disponível)
    duration_ms     INTEGER,                -- Duração do processamento em ms
    error_message   TEXT,                    -- Mensagem de erro (se houver)
    metadata        JSONB DEFAULT '{}'::jsonb, -- Dados extras não previstos

    -- Severidade (OWASP Logging Best Practice)
    severity        TEXT DEFAULT 'info'      -- 'debug' | 'info' | 'warning' | 'error' | 'critical'
                    CHECK (severity IN ('debug', 'info', 'warning', 'error', 'critical')),

    -- Timestamps
    message_timestamp TIMESTAMPTZ,           -- Timestamp da mensagem original do WhatsApp
    created_at      TIMESTAMPTZ DEFAULT NOW() -- Quando o log foi criado
);

-- 2. Índices para consultas de auditoria
CREATE INDEX idx_execution_log_user_phone
    ON public.execution_log (user_phone);

CREATE INDEX idx_execution_log_user_id
    ON public.execution_log (user_id);

CREATE INDEX idx_execution_log_created_at
    ON public.execution_log (created_at DESC);

CREATE INDEX idx_execution_log_event_type
    ON public.execution_log (event_type);

CREATE INDEX idx_execution_log_source_workflow
    ON public.execution_log (source_workflow);

CREATE INDEX idx_execution_log_branch
    ON public.execution_log (branch);

CREATE INDEX idx_execution_log_action_type
    ON public.execution_log (action_type);

CREATE INDEX idx_execution_log_message_type
    ON public.execution_log (message_type);

-- Índice composto para consulta principal do squad auditor
CREATE INDEX idx_execution_log_user_phone_created
    ON public.execution_log (user_phone, created_at DESC);

-- Índice composto para filtrar por usuário + tipo de evento
CREATE INDEX idx_execution_log_user_event
    ON public.execution_log (user_phone, event_type, created_at DESC);

-- 3. Habilitar RLS
ALTER TABLE public.execution_log ENABLE ROW LEVEL SECURITY;

-- 4. Bloquear acesso público (apenas service_role pode ler/escrever)
CREATE POLICY "Bloquear acesso público ao execution_log"
    ON public.execution_log
    FOR ALL
    USING (false)
    WITH CHECK (false);

-- 5. Permitir service_role (N8N usa service_role)
CREATE POLICY "Service role full access to execution_log"
    ON public.execution_log
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- 6. Trigger de IMUTABILIDADE — logs são append-only (boa prática de auditoria)
CREATE OR REPLACE FUNCTION prevent_execution_log_modification()
RETURNS TRIGGER AS $$
BEGIN
  RAISE EXCEPTION 'execution_log is append-only. UPDATE and DELETE are not allowed.';
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tr_execution_log_immutable
  BEFORE UPDATE OR DELETE ON public.execution_log
  FOR EACH ROW
  EXECUTE FUNCTION prevent_execution_log_modification();

-- 7. RPC function para dashboard do analise-total
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
    ),
    'by_severity', (
      SELECT json_object_agg(severity, cnt)
      FROM (
        SELECT severity, COUNT(*) as cnt
        FROM execution_log
        WHERE created_at BETWEEN p_start_date AND p_end_date
        GROUP BY severity
      ) sub
    )
  ) INTO result
  FROM execution_log
  WHERE created_at BETWEEN p_start_date AND p_end_date;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- 8. RPC function para timeline de um usuário específico
CREATE OR REPLACE FUNCTION fn_execution_log_user_timeline(
  p_user_phone TEXT,
  p_start_date TIMESTAMPTZ DEFAULT NOW() - INTERVAL '30 days',
  p_end_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
  id UUID,
  created_at TIMESTAMPTZ,
  event_type TEXT,
  source_workflow TEXT,
  user_message TEXT,
  ai_message TEXT,
  branch TEXT,
  ai_action TEXT,
  action_type TEXT,
  action_success BOOLEAN,
  error_message TEXT,
  severity TEXT,
  message_type TEXT,
  transcription_text TEXT,
  metadata JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    e.id, e.created_at, e.event_type, e.source_workflow,
    e.user_message, e.ai_message, e.branch, e.ai_action,
    e.action_type, e.action_success, e.error_message, e.severity,
    e.message_type, e.transcription_text, e.metadata
  FROM execution_log e
  WHERE e.user_phone = p_user_phone
    AND e.created_at BETWEEN p_start_date AND p_end_date
  ORDER BY e.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- 9. Índice para severity (queries de monitoramento)
CREATE INDEX idx_execution_log_severity
    ON public.execution_log (severity)
    WHERE severity IN ('error', 'critical');

-- 10. Comentários na tabela
COMMENT ON TABLE public.execution_log IS 'Log centralizado de execução para auditoria. Captura cada etapa do processamento de mensagens do Total Assistente.';
COMMENT ON COLUMN public.execution_log.event_type IS 'Tipo do evento: transcription, audio_summary, message_routed, classification, ai_response, action_executed, interaction_complete';
COMMENT ON COLUMN public.execution_log.branch IS 'Classificação de intent: criar_gasto, buscar_gasto, editar_gasto, excluir_gasto, criar_evento, buscar_evento, editar_evento, excluir_evento, criar_lembrete, gerar_relatorio, padrao';
COMMENT ON COLUMN public.execution_log.source_workflow IS 'Workflow de origem: main, premium, standard, financeiro, calendar, lembretes, report';
