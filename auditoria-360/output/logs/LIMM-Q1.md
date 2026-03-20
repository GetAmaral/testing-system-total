# Teste LIMM-Q1

**Funcionalidade:** financeiro/04
**Operacao:** RECUSA_LIMITE
**Data:** 2026-03-20T14:06:35Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "define limite de 3000 por mes" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=86, calendar=313, last_log=3916
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
| last_log_id | 3916 |
| timestamp | 2026-03-20T14:06:35Z |

## Resposta da IA

- log_id: 3917
- ai_message: Não consigo definir limite de gasto por categoria ou criar controle de orçamento. Mas posso gerar um relatório financeiro do mês pra você acompanhar seus gastos, se quiser.

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
11593|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:39
11592|hLwhn94JSHonwHzl|success|2026-03-20T14:06:36
11591|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:33
11590|hLwhn94JSHonwHzl|success|2026-03-20T14:06:30
11589|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:27
```

## Veredicto: PASS

