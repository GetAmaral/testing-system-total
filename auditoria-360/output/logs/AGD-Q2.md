# Teste AGD-Q2

**Funcionalidade:** agenda/01
**Operacao:** CREATE_LEMBRETE
**Data:** 2026-03-20T14:07:20Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "me lembra de beber agua 20h" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | calendar_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=314, last_log=3923
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 88 |
| calendar count | 314 |
| last_log_id | 3923 |
| timestamp | 2026-03-20T14:07:20Z |

## Resposta da IA

- log_id: 3924
- ai_message: ✅ Evento agendado! 📅 Beber Agua ⏰ hoje às 20h

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 315 | 1 |

## Registro no banco

```
active: True
compromisso_tipo: lembrete
created_at: 2026-03-20T11:07:25.855379-03:00
end_event: 2026-03-20T20:15:00-03:00
event_name: Beber Agua
id: 24692177-6706-406a-8909-291d727893c7
is_recurring: False
rrule: None
start_event: 2026-03-20T20:00:00-03:00
```

## Execucoes N8N

```
11609|sSEBeOFFSOapRfu6|error|2026-03-20T14:07:25
11608|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:25
11607|hLwhn94JSHonwHzl|success|2026-03-20T14:07:22
11606|sSEBeOFFSOapRfu6|error|2026-03-20T14:07:17
11605|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:16
```

## Veredicto: PASS_ANOMALY

