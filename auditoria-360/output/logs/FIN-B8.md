# Teste FIN-B8

**Funcionalidade:** financeiro/01
**Operacao:** RECUSA_ACAO
**Data:** 2026-03-20T14:06:14Z
**Veredicto:** PASS

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "paga meu boleto de 200" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=86, calendar=313, last_log=3913
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
| last_log_id | 3913 |
| timestamp | 2026-03-20T14:06:14Z |

## Resposta da IA

- log_id: 3914
- ai_message: Não consigo executar transações, mas posso registrar se já aconteceu. Quer que eu registre?

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
11587|ImW2P52iyCS0bGbQ|success|2026-03-20T14:06:19
11586|hLwhn94JSHonwHzl|success|2026-03-20T14:06:16
11585|NCVLUtTn656ACUGS|success|2026-03-20T14:05:47
11584|NCVLUtTn656ACUGS|success|2026-03-20T14:05:46
11583|ImW2P52iyCS0bGbQ|success|2026-03-20T14:05:49
```

## Veredicto: PASS

