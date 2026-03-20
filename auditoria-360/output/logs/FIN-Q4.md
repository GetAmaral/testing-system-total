# Teste FIN-Q4

**Funcionalidade:** financeiro/01
**Operacao:** EDIT_VALOR
**Data:** 2026-03-20T14:04:40Z
**Veredicto:** VERIFY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "o acai foi 45 nao 38" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | spent_edit |
| Async wait | async |

## Metodo

1. Snapshot ANTES: spent=87, calendar=313, last_log=3911
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
| last_log_id | 3911 |
| timestamp | 2026-03-20T14:04:40Z |

## Resposta da IA

- log_id: 3912
- ai_message: ✅ Edição concluída!  📝 Registro: Açaí 💰 Valor atualizado: R$45,00

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 87 | 0 |
| calendar count | 313 | 0 |

## Registro no banco

```
NOT_FOUND
```

## Execucoes N8N

```
11581|NCVLUtTn656ACUGS|success|2026-03-20T14:04:52
11580|NCVLUtTn656ACUGS|success|2026-03-20T14:04:51
11579|ImW2P52iyCS0bGbQ|success|2026-03-20T14:04:54
11578|hLwhn94JSHonwHzl|success|2026-03-20T14:04:43
11577|NCVLUtTn656ACUGS|success|2026-03-20T14:04:36
```

## Veredicto: VERIFY

