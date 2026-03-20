# Teste PREM-Q1

**Funcionalidade:** bot-whatsapp/02
**Operacao:** FORA_ESCOPO
**Data:** 2026-03-20T14:09:40Z
**Veredicto:** PASS_ANOMALY

---

## Configuracao

| Parametro | Valor |
|-----------|-------|
| Input | "quem e o presidente do Brasil?" |
| Webhook | http://76.13.172.17:5678/webhook/dev-whatsapp |
| User | 2eb4065b-280c-4a50-8b54-4f9329bda0ff (Luiz Felipe) |
| Tipo verificacao | refusal |
| Async wait |  |

## Metodo

1. Snapshot ANTES: spent=88, calendar=316, last_log=3931
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
| last_log_id | 3931 |
| timestamp | 2026-03-20T14:09:40Z |

## Resposta da IA

- log_id: 3932
- ai_message: Não consigo responder esse tipo de సమాచారం externa, mas posso te ajudar com sua agenda, gastos ou relatórios financeiros. Se quiser, me diga o que precisa registrar.

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
11636|ImW2P52iyCS0bGbQ|success|2026-03-20T14:09:44
11635|hLwhn94JSHonwHzl|success|2026-03-20T14:09:41
11634|ImW2P52iyCS0bGbQ|success|2026-03-20T14:09:38
11633|hLwhn94JSHonwHzl|success|2026-03-20T14:09:36
11632|b3xKlSunpwvC4Vwh|error|2026-03-20T14:09:32
```

## Veredicto: PASS_ANOMALY

