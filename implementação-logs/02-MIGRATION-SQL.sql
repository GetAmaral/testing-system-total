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

-- 6. Comentários na tabela
COMMENT ON TABLE public.execution_log IS 'Log centralizado de execução para auditoria. Captura cada etapa do processamento de mensagens do Total Assistente.';
COMMENT ON COLUMN public.execution_log.event_type IS 'Tipo do evento: transcription, audio_summary, message_routed, classification, ai_response, action_executed, interaction_complete';
COMMENT ON COLUMN public.execution_log.branch IS 'Classificação de intent: criar_gasto, buscar_gasto, editar_gasto, excluir_gasto, criar_evento, buscar_evento, editar_evento, excluir_evento, criar_lembrete, gerar_relatorio, padrao';
COMMENT ON COLUMN public.execution_log.source_workflow IS 'Workflow de origem: main, premium, standard, financeiro, calendar, lembretes, report';
