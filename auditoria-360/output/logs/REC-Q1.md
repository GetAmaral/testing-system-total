# Teste REC-Q1

**Funcionalidade:** agenda/06
**Operacao:** CREATE_RECORRENTE
**Data:** 2026-03-20T14:09:25Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "pilates toda segunda e quarta 18h" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | calendar_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=315, last_log=3929
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
| last_log_id | 3929 |
| timestamp | 2026-03-20T14:09:25Z |

## Resposta da IA

- log_id: 3930
- ai_message: ✅ Evento recorrente registrado!  📅 Nome: Pilates 🔁 Quando: Toda segunda e quarta às 18h

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 316 | 1 |

## Registro no banco

```
active: True
compromisso_tipo: compromisso
created_at: 2026-03-20T11:09:32.441522-03:00
end_event: 2026-03-23T18:15:00-03:00
event_name: Pilates
id: fd036b5e-668a-414d-967d-a48da9739495
is_recurring: True
rrule: FREQ=WEEKLY;BYDAY=MO,WE
start_event: 2026-03-23T18:00:00-03:00
```

## Execucoes N8N

```
11632|b3xKlSunpwvC4Vwh|error|2026-03-20T14:09:32
11631|ImW2P52iyCS0bGbQ|success|2026-03-20T14:09:31
11630|hLwhn94JSHonwHzl|success|2026-03-20T14:09:26
11629|sSEBeOFFSOapRfu6|success|2026-03-20T14:08:59
11628|sSEBeOFFSOapRfu6|success|2026-03-20T14:08:58
```

## Veredicto: PASS_ANOMALY

