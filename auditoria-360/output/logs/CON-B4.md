# Teste CON-B4

**Funcionalidade:** agenda/02
**Operacao:** SEARCH_DATA
**Data:** 2026-03-20T14:07:54Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "o que tenho dia 25?" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | search |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3926
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 88 |
| calendar count | 316 |
| last_log_id | 3926 |
| timestamp | 2026-03-20T14:07:54Z |

## Resposta da IA

- log_id: 3927
- ai_message: *Agenda de 25/03*  *quarta-feira, 25/03* 📍 7h - Academia 📍 9h - Beach Tennis 📍 9h - Check-Up 📍 9h30 - Check-Up

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 316 | 0 |

## Registro no banco

```
response_only
```

## Execucoes N8N

```
11621|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:59
11620|ImW2P52iyCS0bGbQ|success|2026-03-20T14:08:01
11619|hLwhn94JSHonwHzl|success|2026-03-20T14:07:56
11618|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:49
11617|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:51
```

## Veredicto: PASS

