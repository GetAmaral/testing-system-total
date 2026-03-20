# Teste CON-Q1

**Funcionalidade:** agenda/02
**Operacao:** SEARCH_AMANHA
**Data:** 2026-03-20T14:07:45Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "o que tenho amanha?" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | search |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3925
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
| last_log_id | 3925 |
| timestamp | 2026-03-20T14:07:45Z |

## Resposta da IA

- log_id: 3926
- ai_message: *Agenda de 21/03*  *sábado, 21/03* 📍 9h - Tomar Um Chá 📍 12h - Churrasco 📍 14h - Reunião Com Parceiro 📍 16h - Futebol 📍 21h - Sair Com Amigos

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
11618|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:49
11617|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:51
11616|hLwhn94JSHonwHzl|success|2026-03-20T14:07:47
11615|sSEBeOFFSOapRfu6|error|2026-03-20T14:07:43
11614|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:40
```

## Veredicto: PASS_ANOMALY

