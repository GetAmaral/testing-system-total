# Teste SUB-Q1

**Funcionalidade:** pagamentos/03
**Operacao:** CONSULTA_PLANO
**Data:** 2026-03-20T14:10:00Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "qual meu plano?" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3934
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
| last_log_id | 3934 |
| timestamp | 2026-03-20T14:10:00Z |

## Resposta da IA

- log_id: 3935
- ai_message: Estou gerando seu relatório do mês agora. Em instantes você terá o resumo dos seus gastos e entradas de março de 2026.

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 88 | 0 |
| calendar count | 316 | 0 |

## Registro no banco

```
nada_criado (spent:88→88 cal:316→316)
```

## Execucoes N8N

```
11643|ImW2P52iyCS0bGbQ|success|2026-03-20T14:10:06
11642|hLwhn94JSHonwHzl|success|2026-03-20T14:10:01
11641|0erjX5QpI9IJEmdi|error|2026-03-20T14:10:00
11640|ImW2P52iyCS0bGbQ|success|2026-03-20T14:09:56
11639|hLwhn94JSHonwHzl|success|2026-03-20T14:09:52
```

## Veredicto: PASS_ANOMALY

