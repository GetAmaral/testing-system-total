# Teste MOD-Q1

**Funcionalidade:** agenda/03
**Operacao:** EDIT_HORARIO
**Data:** 2026-03-20T14:08:03Z
**Veredicto:** VERIFY_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "muda a reuniao do parceiro pra 15h" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | spent_edit |
| Async wait | async |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3927
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
| last_log_id | 3927 |
| timestamp | 2026-03-20T14:08:03Z |

## Resposta da IA

- log_id: 3928
- ai_message: Prontinho, atualizei seu evento.  📅 Nome: Reunião com Parceiro ⏰ Início: amanhã às 15h00 ⏰ Fim: amanhã às 15h30

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 316 | 0 |

## Registro no banco

```
NOT_FOUND
```

## Execucoes N8N

```
11624|sSEBeOFFSOapRfu6|error|2026-03-20T14:08:21
11623|ImW2P52iyCS0bGbQ|success|2026-03-20T14:08:23
11622|hLwhn94JSHonwHzl|success|2026-03-20T14:08:05
11621|sSEBeOFFSOapRfu6|success|2026-03-20T14:07:59
11620|ImW2P52iyCS0bGbQ|success|2026-03-20T14:08:01
```

## Veredicto: VERIFY_ANOMALY

