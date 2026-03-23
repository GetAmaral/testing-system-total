# O Que E o Guardian Deploy

## A analogia: copiloto de aviao

Imagine que voce e um piloto de aviao. Antes de decolar, voce precisa fazer um **checklist**:
combustivel, flaps, instrumentos, comunicacao com a torre... Se esquecer de um item, pode dar problema.

O **Guardian Deploy (Vigil)** e o seu **copiloto**. Ele nao pilota o aviao (nao faz o deploy).
Ele verifica TUDO e te entrega um checklist para voce seguir item por item.

```
Voce (piloto)          = Faz o deploy manual
Vigil (copiloto)       = Verifica tudo e gera o checklist
N8N DEV (simulador)    = Onde voce treina e faz mudancas
N8N PROD (voo real)    = Onde os usuarios reais estao
```

---

## Por que ele existe?

Porque deploy manual doi. Voce ja passou por isso:

- Esqueceu de trocar uma URL de dev por prod
- Esqueceu de trocar um credential ID
- Esqueceu de remover os nodes fake do WhatsApp
- Esqueceu de limpar os dados de teste (pinData)
- Deployou e o sistema quebrou

O Vigil foi criado para que **isso nunca mais aconteca**.

---

## O que ele faz? (3 funcoes)

### Funcao 1: DIFF-CHECK — "O que mudou?"

Antes de fazer mudancas, voce tira uma "foto" (snapshot) do DEV.
Depois de fazer mudancas, voce tira outra "foto".
O Vigil compara as duas e te diz exatamente o que mudou.

```
ANTES                          DEPOIS
[foto do DEV v1]    ->    [foto do DEV v2]
                    |
              Vigil compara
                    |
            "Voce adicionou 3 nodes,
             mudou 2 prompts,
             alterou 1 conexao"
```

### Funcao 2: SPEC-AUDITOR — "Funciona?"

Voce descreve o que fez ("adicionei filtro de categoria no financeiro").
O Vigil cria uma especificacao e testa se as features funcionam,
delegando testes para o Watson (@testador) e a Lupa (@auditor-360).

```
Voce diz:        "Mudei o financeiro para aceitar filtros"
Vigil cria:      Spec com criterios de aceite
Vigil delega:    Watson simula mensagens no DEV
Vigil avalia:    "GO — tudo funcionando" ou "NO-GO — tem problema"
```

### Funcao 3: PRE-DEPLOY — "O que preciso corrigir?" (SUPER-PODER)

Esta e a funcao mais importante. O Vigil escaneia CADA JSON do DEV
e encontra TUDO que precisa ser corrigido antes de ir para PROD.

```
Vigil escaneia:
  - URLs de dev? Encontrei 23! Aqui esta cada uma com o valor correto.
  - Credentials erradas? Encontrei 8! Aqui esta o ID correto para cada node.
  - Nodes fake? Encontrei 3! Remova esses e adicione o trigger real.
  - Dados de teste? Encontrei em 5 workflows! Limpe o pinData.

TOTAL: 34 correcoes necessarias.
Confira que marcou TODAS antes de deployar!
```

---

## O que ele NAO faz?

- Ele **NAO faz deploy**. Voce faz, seguindo o checklist dele.
- Ele **NAO modifica** nenhum workflow. Nem no DEV, nem no PROD.
- Ele **NAO acessa PROD diretamente**. Quem faz isso e o Sherlock (@analisador).
- Ele **NAO envia mensagens** para usuarios reais.

Ele so le, compara, e gera relatorios.

---

## Os comandos (resumo simples)

| Comando | O que faz | Quando usar |
|---------|-----------|-------------|
| `*snapshot` | Tira uma foto do DEV | Antes e depois de mudancas |
| `*diff` | Compara duas fotos | Para ver o que mudou |
| `*spec` | Documenta a mudanca | Quando quer testar features |
| `*audit-spec` | Testa as features | Antes de deployar |
| `*pre-deploy` | Gera checklist granular | Quando vai deployar |
| `*validate-prod` | Verifica PROD apos deploy | Depois de deployar |
| `*lifecycle` | Faz tudo na ordem | Quando quer o ciclo completo |

---

## Como ele se relaciona com os outros agentes?

```
             Vigil (Guardian)
            /    |     |     \
           /     |     |      \
    Watson    Sherlock  Delta   Lupa
  (testador) (analisador)(deploy)(auditor)
      |          |        |       |
   Testa no    Le PROD   Diff    Testa
     DEV      read-only  DEV/PROD features
```

- **Watson** faz os testes no DEV quando o Vigil pede
- **Sherlock** le a producao (read-only) quando o Vigil precisa validar pos-deploy
- **Delta** faz o diff DEV vs PROD quando o Vigil precisa
- **Lupa** testa features especificas quando o Vigil precisa

O Vigil **orquestra** — ele pede, eles executam, ele consolida.

---

## Resumo em uma frase

> O Vigil e o seu copiloto de deploy: ele escaneia tudo, encontra tudo,
> gera um checklist granular, e depois verifica se voce nao esqueceu nada.
