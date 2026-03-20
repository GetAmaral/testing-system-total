# Teste AGD-B1

**Funcionalidade:** agenda/01
**Operacao:** CREATE_DIA_SEMANA
**Data:** 2026-03-20T14:07:29Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "consulta no oftalmo segunda 10h30" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | calendar_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=315, last_log=3924
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 88 |
| calendar count | 315 |
| last_log_id | 3924 |
| timestamp | 2026-03-20T14:07:29Z |

## Resposta da IA

- log_id: 3925
- ai_message: ✅ Evento agendado! 📅 Consulta no Oftalmo ⏰ segunda-feira às 10h30

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 316 | 1 |

## Registro no banco

```
active: True
compromisso_tipo: compromisso
created_at: 2026-03-20T11:07:43.264667-03:00
end_event: 2026-03-23T11:00:00-03:00
event_name: Consulta No Oftalmo
id: 73fe8589-3e9e-4680-be89-15e08c6efac3
is_recurring: False
rrule: None
start_event: 2026-03-23T10:30:00-03:00
```

## Execucoes N8N

```
11615|sSEBeOFFSOapRfu6|error|2026-03-20T14:07:43
11614|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:40
11613|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:36
11612|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:34
11611|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:42
```

## Veredicto: PASS_ANOMALY

