# Teste FIN-B5

**Funcionalidade:** financeiro/01
**Operacao:** SEARCH_CATEGORIA
**Data:** 2026-03-20T14:06:59Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "gastos de alimentacao" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | search |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=313, last_log=3920
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
| last_log_id | 3920 |
| timestamp | 2026-03-20T14:06:59Z |

## Resposta da IA

- log_id: 3922
- ai_message: ✅ Busca completa!  Totais: Saldo: R$173.805,00 Saídas: - R$2.156,00 Entradas: R$175.961,00  Encontrados: 21 registros.  📂 Alimentacao Almoço  - R$42, 16/03/2026 Almoço  - R$45, 16/03/2026 Ifood  - R$8

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 313 | 0 |

## Registro no banco

```
response_only
```

## Execucoes N8N

```
11603|NCVLUtTn656ACUGS|success|2026-03-20T14:07:05
11602|ImW2P52iyCS0bGbQ|success|2026-03-20T14:07:07
11601|hLwhn94JSHonwHzl|success|2026-03-20T14:07:00
11600|NCVLUtTn656ACUGS|error|2026-03-20T14:06:56
11599|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:54
```

## Veredicto: PASS_ANOMALY

