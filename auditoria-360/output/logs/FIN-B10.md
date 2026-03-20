# Teste FIN-B10

**Funcionalidade:** financeiro/01
**Operacao:** CREATE_CENTAVOS
**Data:** 2026-03-20T14:06:50Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "gastei 29.90 de gasolina" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | spent_create |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=87, calendar=313, last_log=3919
2. POST webhook dev com mensagem
3. Poll log_users_messages ate novo log (max 45s, intervalo 3s)
4. Verificar banco imediatamente
5. Snapshot DEPOIS + buscar registro + buscar execucoes N8N
6. Cruzar IA vs banco campo a campo

## Snapshot ANTES

| Metrica | Valor |
|---------|-------|
| spent count | 87 |
| calendar count | 313 |
| last_log_id | 3919 |
| timestamp | 2026-03-20T14:06:50Z |

## Resposta da IA

- log_id: 3920
- ai_message: ✅ Gasto registrado!  📝 Nome: Gasolina 💰 Valor: R$29.9 📚 Categoria: Transporte

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 1 |
| calendar count | 313 | 0 |

## Registro no banco

```
category_spent: Transporte
created_at: 2026-03-20T11:06:56.352534-03:00
date_spent: 2026-03-20T11:06:52.67-03:00
id_spent: 12bc13cd-26b9-4eef-859c-58549c9c785f
name_spent: Gasolina
transaction_type: saida
type_spent: variavel
value_spent: 29.9
```

## Execucoes N8N

```
11600|NCVLUtTn656ACUGS|error|2026-03-20T14:06:56
11599|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:54
11598|hLwhn94JSHonwHzl|success|2026-03-20T14:06:51
11597|NCVLUtTn656ACUGS|error|2026-03-20T14:06:48
11596|NCVLUtTn656ACUGS|error|2026-03-20T14:06:44
```

## Veredicto: PASS_ANOMALY

