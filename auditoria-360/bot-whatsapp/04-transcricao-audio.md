# Metodologia de Auditoria — Transcrição de Áudio

**Funcionalidade:** `bot-whatsapp/04-transcricao-audio`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp envia áudio → Main (webhook trigger)
  → Switch (tipo de mídia) → branch "audio"
    → Get Media Info1 (httpRequest) — busca URL do arquivo na Meta API
    → Download File1 (httpRequest) — baixa o arquivo de áudio
    → Transcribe a recording (OpenAI Whisper) — transcreve para texto
    → Texto transcrito segue fluxo normal (Premium/Standard)
      → Se Premium: Fix Conflito v2 processa como se fosse texto digitado
```

### Nós no Main

| Nó | Tipo | Função |
|----|------|--------|
| `Switch` output audio | switch | Detecta tipo=audio no payload |
| `Get Media Info1` | httpRequest | GET Meta API para URL do áudio |
| `Download File1` | httpRequest | Baixa o arquivo .ogg/.mp3 |
| `Transcribe a recording` | openAi (Whisper) | Transcreve áudio → texto |

### Limitação de teste via webhook

**Watson NÃO consegue enviar áudio real via webhook simulado.** O payload WhatsApp para áudio tem formato diferente:

```json
{
  "messages": [{
    "type": "audio",
    "audio": {
      "id": "MEDIA_ID",
      "mime_type": "audio/ogg; codecs=opus"
    }
  }]
}
```

O `Get Media Info1` faz GET na Meta API com o `MEDIA_ID` — que precisa ser um ID real. Webhook simulado não tem arquivo de áudio real na Meta.

---

## 2. Estratégia de teste

### O que Watson PODE testar:
1. **Verificar que o Switch roteia áudio corretamente** — inspecionar nós do workflow
2. **Verificar execuções passadas** — buscar execuções que processaram áudio
3. **Verificar log de transcrições** — buscar em log_users_messages mensagens que vieram de áudio
4. **Verificar que o nó Whisper está configurado** — modelo, idioma

### O que Watson NÃO pode testar:
1. Enviar áudio real (precisa do app WhatsApp)
2. Qualidade da transcrição (depende do áudio real)
3. Download do arquivo da Meta API (precisa de MEDIA_ID real)

---

## 3. Algoritmo de execução

```
PASSO 1 — ANÁLISE ESTÁTICA
  1.1  GET /api/v1/workflows/hLwhn94JSHonwHzl (Main)
  1.2  Verificar nó "Transcribe a recording":
       - model: whisper-1?
       - language: pt?
       - Está conectado corretamente ao fluxo?

PASSO 2 — ANÁLISE DE EXECUÇÕES PASSADAS
  2.1  GET /executions?workflowId=hLwhn94JSHonwHzl&limit=50
  2.2  Filtrar execuções que passaram pelo nó de transcrição
  2.3  Verificar status dessas execuções (success/error)

PASSO 3 — ANÁLISE DE LOGS
  3.1  Buscar log_users_messages onde o user_message parece ser transcrição
       (textos que não foram digitados — podem ter marcadores)
  3.2  Verificar se a IA processou o texto transcrito corretamente

PASSO 4 — REGISTRAR
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Nó Whisper configurado | model=whisper-1, language=pt | Mal configurado |
| 2 | Switch roteia áudio | Output "audio" existe e está conectado | Desconectado |
| 3 | Execuções passadas | Existem execuções com áudio que deram success | Todas error |
| 4 | Texto transcrito processado | Após transcrição, segue fluxo normal (gasto/agenda/etc) | Para na transcrição |

---

## 5. Protocolo de diagnóstico de erros

```
CAMADA 1 — SWITCH: Mensagem de áudio não foi pro branch correto?
CAMADA 2 — META API: Get Media Info falhou? (token expirado, rate limit)
CAMADA 3 — DOWNLOAD: Arquivo não baixou? (timeout, formato)
CAMADA 4 — WHISPER: Transcrição falhou? (modelo, quota OpenAI)
CAMADA 5 — DOWNSTREAM: Texto transcrito não foi processado pelo Premium/Standard?
```

---

## 6. Testes

**🟢 Quick (2 testes):**

| ID | Input | Tipo | Verificação |
|----|-------|------|-------------|
| AUD-Q1 | Análise estática do workflow | Inspeção | Nó Whisper existe e está conectado |
| AUD-Q2 | Execuções passadas com áudio | Histórico | Alguma execução com áudio deu success |

**🟡 Broad (Quick + 3 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| AUD-B1 | Verificar modelo Whisper | whisper-1, language=pt |
| AUD-B2 | Buscar erros de transcrição | Execuções com error no nó Transcribe |
| AUD-B3 | Log de mensagens transcritas | Existem ai_messages que responderam a áudios |

**🔴 Complete (Broad + 2 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| AUD-C1 | Enviar payload de áudio simulado | Verificar comportamento do Switch (pode falhar no download) |
| AUD-C2 | Verificar quota/custo Whisper | Nó tem configuração de retry/fallback? |

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Logar "fonte=audio" no log_users_messages | Saber quais mensagens vieram de áudio |
| Criar user de teste com áudio real | Teste end-to-end completo |
| Fallback se Whisper falhar | Avisar user que não entendeu o áudio |
