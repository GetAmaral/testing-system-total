-- Criar essa função no Supabase (SQL Editor)
-- Ela incrementa total_nao e marca opted_out se >= 2

CREATE OR REPLACE FUNCTION public.gc_nudge_registrar_nao(p_user_id uuid)
RETURNS void AS $$
BEGIN
  INSERT INTO public.gc_nudge (user_id, last_response, last_response_at, total_nao, opted_out)
  VALUES (p_user_id, 'nao', now(), 1, false)
  ON CONFLICT (user_id) DO UPDATE SET
    last_response = 'nao',
    last_response_at = now(),
    total_nao = gc_nudge.total_nao + 1,
    opted_out = CASE WHEN gc_nudge.total_nao + 1 >= 2 THEN true ELSE false END;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
