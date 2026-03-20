# Teste DEL-Q1

**Funcionalidade:** agenda/04
**Operacao:** DELETE_EVENTO
**Data:** 2026-03-20T14:08:47Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "cancela a consulta no oftalmo" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | cal_delete |
| Async wait | async |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3928
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Esperar 22s para async completar
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 88 |
| calendar count | 316 |
| last_log_id | 3928 |
| timestamp | 2026-03-20T14:08:47Z |

## Resposta da IA

- log_id: 3929
- ai_message: 🗑️ Evento excluído!  📅 Nome: Consulta No Oftalmo ⏰ Início: 23/03/2026 às 10:30 ⏰ Fim: 23/03/2026 às 11:00

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 315 | -1 |

## Registro no banco

```
cal:316→315 evento:GONE
```

## Execucoes N8N

```
11629|sSEBeOFFSOapRfu6|success|2026-03-20T14:08:59
11628|sSEBeOFFSOapRfu6|success|2026-03-20T14:08:58
11627|sSEBeOFFSOapRfu6|success|2026-03-20T14:08:55
11626|ImW2P52iyCS0bGbQ|success|2026-03-20T14:09:00
11625|hLwhn94JSHonwHzl|success|2026-03-20T14:08:49
```

## Veredicto: PASS

