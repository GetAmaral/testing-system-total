# Teste FIN-B1

**Funcionalidade:** financeiro/01
**Operacao:** CREATE_GIRIA
**Data:** 2026-03-20T14:06:41Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "torrei 55 conto no boteco" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | spent_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=86, calendar=313, last_log=3917
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 86 |
| calendar count | 313 |
| last_log_id | 3917 |
| timestamp | 2026-03-20T14:06:41Z |

## Resposta da IA

- log_id: 3919
- ai_message: ✅ Gasto registrado!  📝 Nome: Boteco 💰 Valor: R$55 📚 Categoria: Lazer

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 87 | 1 |
| calendar count | 313 | 0 |

## Registro no banco

```
category_spent: Lazer
created_at: 2026-03-20T11:06:48.413179-03:00
date_spent: 2026-03-20T11:06:43.578-03:00
id_spent: 5eb81081-1ce1-4c93-9322-eea30e94b4df
name_spent: Boteco
transaction_type: saida
type_spent: variavel
value_spent: 55
```

## Execucoes N8N

```
11597|NCVLUtTn656ACUGS|error|2026-03-20T14:06:48
11596|NCVLUtTn656ACUGS|error|2026-03-20T14:06:44
11595|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:46
11594|hLwhn94JSHonwHzl|success|2026-03-20T14:06:42
11593|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:39
```

## Veredicto: PASS_ANOMALY

