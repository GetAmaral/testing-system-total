# Teste META-Q1

**Funcionalidade:** financeiro/03
**Operacao:** RECUSA_META
**Data:** 2026-03-20T14:06:29Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "quero criar uma meta de economizar 500" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=86, calendar=313, last_log=3915
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
| last_log_id | 3915 |
| timestamp | 2026-03-20T14:06:29Z |

## Resposta da IA

- log_id: 3916
- ai_message: Não consigo montar metas ou planejamentos financeiros. Se quiser, posso gerar seu relatório do mês pra você ter uma visão dos gastos.

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
11591|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:33
11590|hLwhn94JSHonwHzl|success|2026-03-20T14:06:30
11589|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:27
11588|hLwhn94JSHonwHzl|success|2026-03-20T14:06:25
11587|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:19
```

## Veredicto: PASS

