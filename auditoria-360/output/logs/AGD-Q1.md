# Teste AGD-Q1

**Funcionalidade:** agenda/01
**Operacao:** CREATE_EVENTO
**Data:** 2026-03-20T14:07:11Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "reuniao com parceiro amanha 14h" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | calendar_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=313, last_log=3922
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 88 |
| calendar count | 313 |
| last_log_id | 3922 |
| timestamp | 2026-03-20T14:07:11Z |

## Resposta da IA

- log_id: 3923
- ai_message: ✅ Evento agendado! 📅 Reunião com Parceiro ⏰ amanhã às 14h

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 314 | 1 |

## Registro no banco

```
active: True
compromisso_tipo: compromisso
created_at: 2026-03-20T11:07:17.262534-03:00
end_event: 2026-03-21T14:30:00-03:00
event_name: Reunião Com Parceiro
id: 2f733302-2efe-4707-b792-ac412008b3f8
is_recurring: False
rrule: None
start_event: 2026-03-21T14:00:00-03:00
```

## Execucoes N8N

```
11606|sSEBeOFFSOapRfu6|error|2026-03-20T14:07:17
11605|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:16
11604|hLwhn94JSHonwHzl|success|2026-03-20T14:07:13
11603|NCVLUtTn656ACUGS|success|2026-03-20T14:07:05
11602|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:07
```

## Veredicto: PASS_ANOMALY

