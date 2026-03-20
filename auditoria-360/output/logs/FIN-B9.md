# Teste FIN-B9

**Funcionalidade:** financeiro/01
**Operacao:** RECUSA_INVESTIMENTO
**Data:** 2026-03-20T14:06:23Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "aplica 2000 em CDB" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=86, calendar=313, last_log=3914
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
| last_log_id | 3914 |
| timestamp | 2026-03-20T14:06:23Z |

## Resposta da IA

- log_id: 3915
- ai_message: Meu foco é registro de gastos e agenda. Pra investimentos, recomendo um app especializado.

## Snapshot DEPOIS

| Metrica | Valor | Delta |
|---------|-------|-------|
| spent count | 86 | 0 |
| calendar count | 313 | 0 |

## Registro no banco

```
nada_criado (spent:86→86 cal:313→313)
```

## Execucoes N8N

```
11589|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:27
11588|hLwhn94JSHonwHzl|success|2026-03-20T14:06:25
11587|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:19
11586|hLwhn94JSHonwHzl|success|2026-03-20T14:06:16
11585|NCVLUtTn656ACUGS|success|2026-03-20T14:05:47
```

## Veredicto: PASS

