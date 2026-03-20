# Teste FIN-Q5

**Funcionalidade:** financeiro/01
**Operacao:** DELETE_GASTO
**Data:** 2026-03-20T14:05:19Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "apaga o acai" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | spent_delete |
| Async wait | async |

## Metodo

1. Snapshot ANTES: spent=87, calendar=313, last_log=3912
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Esperar 22s para async completar
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 87 |
| calendar count | 313 |
| last_log_id | 3912 |
| timestamp | 2026-03-20T14:05:19Z |

## Resposta da IA

- log_id: 3913
- ai_message: 🗑️ Exclusão concluída!  📝 Registro: Açaí 💰 Valor: R$45 🗓️ Data: 20/03/2026

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 86 | -1 |
| calendar count | 313 | 0 |

## Registro no banco

```
spent:87→86
```

## Execucoes N8N

```
11585|NCVLUtTn656ACUGS|success|2026-03-20T14:05:47
11584|NCVLUtTn656ACUGS|success|2026-03-20T14:05:46
11583|ImW2P52iyCS0bGbQ|success|2026-03-20T14:05:49
11582|hLwhn94JSHonwHzl|success|2026-03-20T14:05:21
11581|NCVLUtTn656ACUGS|success|2026-03-20T14:04:52
```

## Veredicto: PASS

