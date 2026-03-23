# Como Usar — Passo a Passo

## Passo 0: Ativar o Vigil

```
@guardian
```

Ele vai cumprimentar voce:
```
🛡️ Vigil (Guardian) pronto. Copiloto de deploy ativo. Nada escapa. O que fazemos?
```

---

## Cenario 1: "Vou fazer mudancas no DEV"

### Passo 1 — Tire uma foto ANTES

```
*snapshot pre-minha-mudanca
```

O que acontece:
- Vigil acessa o N8N DEV via API
- Exporta todos os 6 workflows como JSON
- Limpa dados de teste (pinData)
- Salva tudo em `data/snapshots/` com a data e o label que voce deu

Resultado:
```
Snapshot 'pre-minha-mudanca' capturado com sucesso.
6 workflows salvos.
Path: data/snapshots/2026-03-23_14-30_pre-minha-mudanca/
```

### Passo 2 — Faca suas mudancas no N8N DEV

Agora voce trabalha normalmente no N8N DEV (http://76.13.172.17:5678).
Adicione nodes, mude prompts, altere conexoes, faca o que precisar.

### Passo 3 — Tire uma foto DEPOIS

```
*snapshot pos-minha-mudanca
```

### Passo 4 — Veja o que mudou

```
*diff --latest
```

Resultado (exemplo):
```
DIFF: pre-minha-mudanca vs pos-minha-mudanca

Financeiro - Total:
  NODES ADICIONADOS:
    + "Filtrar por Categoria" (type: code) — novo node de filtragem
  NODES MODIFICADOS:
    ~ "AI Agent" — system message mudou (prompt de busca atualizado)
  CONNECTIONS:
    + "Switch" -> "Filtrar por Categoria" (nova conexao)
    + "Filtrar por Categoria" -> "HTTP Request" (nova conexao)

Risco geral: MEDIUM
```

---

## Cenario 2: "Quero testar as mudancas"

### Passo 5 — Crie uma spec

```
*spec "Adicionei filtro de categoria no financeiro para buscar gastos por tipo"
```

O Vigil vai perguntar:
```
? Quais workflows foram afetados?
  1. Main - Total Assistente
  2. Calendar WebHooks
  3. Financeiro - Total  <-- voce seleciona este
  ...

? Existe um diff report para referencia?
  1. Sim (usar o mais recente)
  2. Nao
```

Resultado: uma spec com criterios de aceite.

### Passo 6 — Teste contra a spec

```
*audit-spec --auto
```

O Vigil delega testes ao Watson e a Lupa, depois te da o resultado:
```
VEREDICTO: GO

Criterios de aceite:
  [PASS] Filtro de categoria funciona com "alimentacao"
  [PASS] Filtro de categoria funciona com "lazer"
  [PASS] Busca sem filtro continua funcionando (regressao OK)
  [PASS] Nenhuma credential exposta
  [PASS] Performance: node count +1, aceitavel
```

---

## Cenario 3: "Vou deployar para PROD" (o mais importante!)

### Passo 7 — Gere o checklist granular

```
*pre-deploy
```

Este e o **super-poder** do Vigil. Ele escaneia CADA JSON e te entrega:

```
============================================
CHECKLIST DE DEPLOY — DEV -> PROD
Total de correcoes: 34 itens
============================================

## Financeiro - Total (PROD ID: eYWjnmvP8LQxY87g)

### URLs DEV -> PROD
[ ] Node "HTTP Request" (httpRequest): campo url
    DE: http://n8n-fcwk0sw4soscgsgs08g8gssk.76.13.172.17.sslip.io/webhook/filtros-supabase
    PARA: https://totalassistente.com.br/webhook/filtros-supabase

[ ] Node "HTTP Request1" (httpRequest): campo url
    DE: http://n8n-zcgwwscwc8coos88c0g08sks.76.13.172.17.sslip.io/webhook/registrar-gasto
    PARA: https://totalassistente.com.br/webhook/registrar-gasto

### Credentials
[ ] Node "Supabase - Create a row" (supabase): credential
    DE: fGwpKYpERyVmR2tt (Supabase dev)
    PARA: 1ENA7UIm6ILehilJ (Supabase prod)

### pinData
[ ] Limpar pinData (nodes: Filtrar por Categoria, AI Agent)

---

## Main - Total Assistente (PROD ID: 9WDlyel5xRCLAvtH)

### CRITICO: WhatsApp Trigger
[ ] REMOVER node "trigger-whatsappsdadsa" (webhook fake)
[ ] REMOVER node "Normalize WhatsApp payload" (code node)
[ ] REMOVER node "trigger-whatsapp" (code node fake)
[ ] ADICIONAR trigger real: n8n-nodes-base.whatsAppTrigger
    Credential: WhatsApp OAuth account (ID: LBPenwzFCkBeUYSp)
    Conexao: trigger-whatsapp -> Edit Fields

### URLs DEV -> PROD
[ ] Node "HTTP Request" (httpRequest): campo url
    DE: http://76.13.172.17:5678/webhook/...
    PARA: https://totalassistente.com.br/webhook/...
(... mais itens ...)

---

CONTAGEM FINAL:
  URLs: 23 | Credentials: 8 | Nodes: 3+1 | pinData: 5
  TOTAL: 34 correcoes

  CONFIRA QUE MARCOU TODOS OS 34 ITENS ANTES DE DEPLOYAR!
```

### Passo 8 — Execute o deploy (VOCE faz, nao o Vigil)

Siga o checklist item por item. Marque cada `[ ]` conforme executa.
Ao final, confirme que o numero de itens marcados bate com o total.

### Passo 9 — Valide PROD

```
*validate-prod
```

O Vigil pede ao Sherlock (@analisador) para verificar PROD:

```
VALIDACAO POS-DEPLOY

Containers:          8/8 rodando [OK]
Erros nos logs:      0 criticos [OK]
URLs de dev:         0 encontradas [OK]
Credentials de dev:  0 encontradas [OK]
WhatsApp trigger:    Real (whatsAppTrigger) [OK]
pinData:             0 workflows [OK]
Workflows ativos:    8/8 [OK]

VEREDICTO: ALL_CLEAR — Deploy concluido com sucesso!
```

Se algo estivesse errado:
```
VEREDICTO: CRITICAL_FAILURE

URLs de dev: 2 encontradas!
  - Main: Node "HTTP Request3" ainda tem 76.13.172.17
  - Calendar: Node "Webhook Sync" ainda tem sslip.io

ACAO: Corrigir IMEDIATAMENTE ou executar rollback.
Rollback: dizer "RESTAURAR GOLDEN BACKUP"
```

---

## Cenario 4: "Quero o ciclo completo de uma vez"

```
*lifecycle
```

O Vigil executa tudo na ordem:
1. Snapshot pre-mudanca
2. (pausa — voce faz mudancas)
3. Snapshot pos-mudanca
4. Diff entre versoes
5. Criar spec
6. Auditar spec
7. Gerar checklist
8. (pausa — voce faz o deploy)
9. Validar PROD

---

## Dicas importantes

### Nunca pule o `*pre-deploy`
Mesmo que voce ache que "ja troquei tudo", rode o scan. Ele pode encontrar coisas que voce nao sabia que precisavam mudar.

### Nunca pule o `*validate-prod`
Depois de deployar, SEMPRE verifique. E rapido e pode salvar voce de um problema grave.

### Se o Vigil parar e perguntar algo
E porque ele esta em duvida. Responda antes de ele continuar. Ele e cauteloso de proposito.

### Os relatorios ficam salvos
Tudo que o Vigil gera fica em `guardian-deploy/output/`. Voce pode consultar depois.
