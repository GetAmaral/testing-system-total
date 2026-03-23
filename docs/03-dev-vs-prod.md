# DEV vs PROD — Nunca Confunda

## Por que isso importa?

DEV e PROD sao dois mundos completamente diferentes. Confundir um com o outro pode:
- **Derrubar o sistema** para usuarios reais
- **Expor dados de teste** em producao
- **Quebrar o WhatsApp** do Total Assistente

Este documento existe para que voce NUNCA confunda os dois.

---

## Visao Geral (tabela rapida)

| | DEV | PROD |
|---|---|---|
| **Cor mental** | Verde (seguro) | Vermelho (cuidado!) |
| **IP** | `76.13.172.17` | `188.245.190.178` |
| **URL** | `http://76.13.172.17:5678` | `https://n8n.totalassistente.com.br` |
| **Protocolo** | HTTP (sem cadeado) | HTTPS (com cadeado) |
| **Dominio** | Nenhum (acesso por IP) | `totalassistente.com.br` |
| **Versao N8N** | 2.11.2 (mais nova) | 2.4.4 |
| **Containers** | 1 (N8N unico) | 8 (N8N + worker + webhook + postgres + redis + rabbitmq + site + gotenberg) |
| **WhatsApp** | FAKE (webhook simulado) | REAL (OAuth + Meta) |
| **Usuarios** | Luiz Felipe (teste) | PESSOAS REAIS |
| **SSH** | Nao temos | Sim (`~/.ssh/totalassistente`) |
| **Quem acessa** | Voce + Watson + Lupa | SOMENTE Sherlock (read-only) |

---

## Como saber se e DEV ou PROD?

### Regra 1: Olhe o IP

```
76.13.172.17     = DEV (pode mexer)
188.245.190.178  = PROD (NUNCA mexer)
```

### Regra 2: Olhe o dominio

```
Sem dominio (IP puro)         = DEV
totalassistente.com.br        = PROD
n8n.totalassistente.com.br    = PROD
```

### Regra 3: Olhe o protocolo

```
http://   = DEV (sem SSL)
https://  = PROD (com SSL)
```

### Regra 4: Olhe a URL completa no N8N

Se voce ve isso dentro de um workflow:
```
http://n8n-fcwk0sw4soscgsgs08g8gssk.76.13.172.17.sslip.io  = DEV
http://n8n-zcgwwscwc8coos88c0g08sks.76.13.172.17.sslip.io  = DEV
https://totalassistente.com.br                               = PROD
```

Se tem `sslip.io` na URL = e DEV. Se tem `totalassistente.com.br` = e PROD.

---

## As 4 armadilhas do deploy

### Armadilha 1: URLs de DEV que sobram

No DEV, os workflows usam URLs com `76.13.172.17` ou `sslip.io`.
Se voce deployar sem trocar, o workflow de PROD vai tentar chamar o DEV.

```
ERRADO (ficou DEV em PROD):
  Node "HTTP Request" -> http://76.13.172.17:5678/webhook/filtros-supabase
                          ^^^^^^^^^^^^^^^^
                          IP DO DEV!

CERTO (corrigido para PROD):
  Node "HTTP Request" -> https://totalassistente.com.br/webhook/filtros-supabase
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                          DOMINIO DO PROD!
```

**O Vigil encontra TODAS essas URLs automaticamente com `*pre-deploy`.**

### Armadilha 2: Credential ID errado

No DEV, o Supabase usa o credential ID `fGwpKYpERyVmR2tt`.
Na PROD, o credential ID e `1ENA7UIm6ILehilJ`.

Se voce nao trocar, o workflow de PROD nao consegue acessar o banco.

```
ERRADO:  credential "fGwpKYpERyVmR2tt" -> nao existe em PROD -> ERRO
CERTO:   credential "1ENA7UIm6ILehilJ" -> funciona em PROD -> OK
```

**O Vigil lista CADA node que precisa trocar credential.**

### Armadilha 3: WhatsApp trigger fake

No DEV, o Main workflow usa 3 nodes fake para simular mensagens:
- `trigger-whatsappsdadsa` (webhook fake)
- `Normalize WhatsApp payload` (code node)
- `trigger-whatsapp` (code node, NAO e o trigger real)

Na PROD, precisa do trigger REAL:
- `trigger-whatsapp` tipo `n8n-nodes-base.whatsAppTrigger` com OAuth

```
DEV (fake):   webhook fake -> code normaliza -> code transforma -> Edit Fields
PROD (real):  whatsAppTrigger (OAuth) -> Edit Fields
```

Se voce deployar com os nodes fake, o WhatsApp para de funcionar em PROD.

**O Vigil detecta os nodes fake e gera instrucoes para trocar pelo real.**

### Armadilha 4: pinData (dados de teste)

Quando voce testa no DEV, o N8N salva dados nos nodes (pinData).
Esses dados de teste NAO devem ir para PROD.

```
ERRADO: Workflow de PROD com pinData do Luiz Felipe (usuario de teste)
CERTO:  Workflow de PROD com pinData limpo (null)
```

**O Vigil detecta pinData e gera item no checklist para limpar.**

---

## IDs de Workflow — Sao DIFERENTES!

O MESMO workflow tem ID diferente no DEV e no PROD. Isso e normal no N8N.

| Workflow | ID no DEV | ID na PROD |
|----------|-----------|------------|
| Main | hLwhn94JSHonwHzl | 9WDlyel5xRCLAvtH |
| Fix Conflito v2 / User Premium | ImW2P52iyCS0bGbQ | tyJ3YAAtSg1UurFj |
| Financeiro | NCVLUtTn656ACUGS | eYWjnmvP8LQxY87g |
| Calendar | sSEBeOFFSOapRfu6 | ZZbMdcuCKx0fM712 |
| Lembretes | b3xKlSunpwvC4Vwh | sjDpjKqtwLk7ycki |
| Report/Relatorios | 0erjX5QpI9IJEmdi | S2QgrsN6uteyB04E |
| User Standard | (nao existe) | c8gtSmh1BPzZXbJa |
| Service Message | (nao existe) | GNdoIS2zxGBa4CW0 |

**Quando o checklist diz "PROD ID: eYWjnmvP8LQxY87g", e esse o ID que voce usa na API.**

---

## Workflows que so existem em PROD

Estes workflows NAO existem no DEV. Voce NAO TOCA neles durante o deploy:

| Workflow | PROD ID | Por que nao tocar |
|----------|---------|-------------------|
| Service Message - 24 Hours | GNdoIS2zxGBa4CW0 | Nao tem versao DEV. Funciona como esta. |
| My workflow | uzbB6BQ3gf0s3tTqEKGsX | Workflow de teste inativo. Ignorar. |

---

## Credential IDs — Tabela de referencia

| Credential | ID DEV | ID PROD | Acao no deploy |
|------------|--------|---------|----------------|
| Supabase account | `fGwpKYpERyVmR2tt` | `1ENA7UIm6ILehilJ` | TROCAR |
| Redis (Upstash/Germany) | `amNI4dVfk3J8Bz0v` | `amNI4dVfk3J8Bz0v` | Nada (mesmo ID) |
| WhatsApp OAuth | `LBPenwzFCkBeUYSp` | `LBPenwzFCkBeUYSp` | Nada (mesmo ID) |

---

## Supabase — Tambem sao diferentes

| | DEV | PROD |
|---|---|---|
| Nome | AI Messages | Principal |
| Ref | `hkzgttizcfklxfafkzfl` | `ldbdtakddxznfridsarn` |
| URL | `https://hkzgttizcfklxfafkzfl.supabase.co` | `https://ldbdtakddxznfridsarn.supabase.co` |
| Uso | Logs de teste | Dados reais de usuarios |

---

## Resumo: como nao errar

1. **Sempre rode `*pre-deploy`** antes de deployar — ele encontra tudo
2. **Marque cada `[ ]`** do checklist conforme executa
3. **Confira a contagem final** — se marcou menos que o total, faltou algo
4. **Rode `*validate-prod`** depois do deploy — ele escaneia PROD em busca de restos de DEV
5. **Se der problema** — diga "RESTAURAR GOLDEN BACKUP"
