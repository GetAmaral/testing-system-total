-- ============================
-- AUDIT TRIGGERS — Total Assistente
-- Rodar no Supabase SQL Editor do banco Principal
-- ============================

-- AUDIT PARA TABELA SPENT
CREATE TABLE IF NOT EXISTS audit_spent (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  changed_fields TEXT[],
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT DEFAULT 'n8n'
);

CREATE OR REPLACE FUNCTION fn_audit_spent()
RETURNS TRIGGER AS $$
DECLARE
  changed TEXT[] := '{}';
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_spent(action, record_id, new_values)
    VALUES ('INSERT', NEW.id_spent, to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.name_spent IS DISTINCT FROM NEW.name_spent THEN changed := changed || 'name_spent'; END IF;
    IF OLD.value_spent IS DISTINCT FROM NEW.value_spent THEN changed := changed || 'value_spent'; END IF;
    IF OLD.category_spent IS DISTINCT FROM NEW.category_spent THEN changed := changed || 'category_spent'; END IF;
    IF OLD.transaction_type IS DISTINCT FROM NEW.transaction_type THEN changed := changed || 'transaction_type'; END IF;
    IF OLD.type_spent IS DISTINCT FROM NEW.type_spent THEN changed := changed || 'type_spent'; END IF;
    IF OLD.date_spent IS DISTINCT FROM NEW.date_spent THEN changed := changed || 'date_spent'; END IF;
    INSERT INTO audit_spent(action, record_id, old_values, new_values, changed_fields)
    VALUES ('UPDATE', NEW.id_spent, to_jsonb(OLD), to_jsonb(NEW), changed);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_spent(action, record_id, old_values)
    VALUES ('DELETE', OLD.id_spent, to_jsonb(OLD));
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_spent ON spent;
CREATE TRIGGER trg_audit_spent
AFTER INSERT OR UPDATE OR DELETE ON spent
FOR EACH ROW EXECUTE FUNCTION fn_audit_spent();


-- AUDIT PARA TABELA CALENDAR
CREATE TABLE IF NOT EXISTS audit_calendar (
  id SERIAL PRIMARY KEY,
  action TEXT NOT NULL,
  record_id UUID,
  old_values JSONB,
  new_values JSONB,
  changed_fields TEXT[],
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  source TEXT DEFAULT 'n8n'
);

CREATE OR REPLACE FUNCTION fn_audit_calendar()
RETURNS TRIGGER AS $$
DECLARE
  changed TEXT[] := '{}';
BEGIN
  IF TG_OP = 'INSERT' THEN
    INSERT INTO audit_calendar(action, record_id, new_values)
    VALUES ('INSERT', NEW.id, to_jsonb(NEW));
    RETURN NEW;
  ELSIF TG_OP = 'UPDATE' THEN
    IF OLD.event_name IS DISTINCT FROM NEW.event_name THEN changed := changed || 'event_name'; END IF;
    IF OLD.start_event IS DISTINCT FROM NEW.start_event THEN changed := changed || 'start_event'; END IF;
    IF OLD.end_event IS DISTINCT FROM NEW.end_event THEN changed := changed || 'end_event'; END IF;
    IF OLD.active IS DISTINCT FROM NEW.active THEN changed := changed || 'active'; END IF;
    IF OLD.is_recurring IS DISTINCT FROM NEW.is_recurring THEN changed := changed || 'is_recurring'; END IF;
    IF OLD.rrule IS DISTINCT FROM NEW.rrule THEN changed := changed || 'rrule'; END IF;
    INSERT INTO audit_calendar(action, record_id, old_values, new_values, changed_fields)
    VALUES ('UPDATE', NEW.id, to_jsonb(OLD), to_jsonb(NEW), changed);
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    INSERT INTO audit_calendar(action, record_id, old_values)
    VALUES ('DELETE', OLD.id, to_jsonb(OLD));
    RETURN OLD;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_audit_calendar ON calendar;
CREATE TRIGGER trg_audit_calendar
AFTER INSERT OR UPDATE OR DELETE ON calendar
FOR EACH ROW EXECUTE FUNCTION fn_audit_calendar();


-- PERMISSÕES: liberar SELECT para service_role (Watson)
ALTER TABLE audit_spent ENABLE ROW LEVEL SECURITY;
CREATE POLICY "service_role_read_audit_spent" ON audit_spent
  FOR SELECT USING (true);

ALTER TABLE audit_calendar ENABLE ROW LEVEL SECURITY;
CREATE POLICY "service_role_read_audit_calendar" ON audit_calendar
  FOR SELECT USING (true);
