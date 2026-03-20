# Teste FIN-Q3

**Funcionalidade:** financeiro/01
**Operacao:** SEARCH_GASTOS
**Data:** 2026-03-20T14:04:31Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "quanto gastei hoje?" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | search |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=87, calendar=313, last_log=3910
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
| last_log_id | 3910 |
| timestamp | 2026-03-20T14:04:31Z |

## Resposta da IA

- log_id: 3911
- ai_message: ✅ Busca completa!  Totais: Saldo: R$2.897,00 Saídas: - R$103,00 Entradas: R$3.600,00  Encontrados: 5 registros.  📂 Alimentação Açaí  - R$38,00, 20/03/2026 Sushi  - R$45,00, 20/03/2026  📂 Outros Trabal

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 87 | 0 |
| calendar count | 313 | 0 |

## Registro no banco

```
response_only
```

## Execucoes N8N

```
11577|NCVLUtTn656ACUGS|success|2026-03-20T14:04:36
11576|ImW2P52iyCS0bGbQ|success|2026-03-20T14:04:39
11575|hLwhn94JSHonwHzl|success|2026-03-20T14:04:33
11574|NCVLUtTn656ACUGS|error|2026-03-20T14:04:31
11573|ImW2P52iyCS0bGbQ|success|2026-03-20T14:04:29
```

## Veredicto: PASS_ANOMALY

