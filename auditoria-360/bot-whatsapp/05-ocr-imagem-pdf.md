# Metodologia de Auditoria — OCR de Imagens e PDFs

**Funcionalidade:** `bot-whatsapp/05-ocr-imagem-pdf`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp envia imagem/PDF → Main (webhook trigger)
  → Switch (tipo de mídia) → branch "image" ou "document"
    → Get Media Info (httpRequest) → Download File (httpRequest)
    → Segue para Fix Conflito v2

Fix Conflito v2:
  → If1 (detecta se tem arquivo)
    → Se imagem: HTTP Request6 (Vision API / análise de imagem)
    → Se PDF: PDF Extractor (httpRequest) → Code (extrai texto)
    → Texto extraído → Escolher Branch → fluxo normal
```

### Nós relevantes no Fix Conflito v2

| Nó | Tipo | Função |
|----|------|--------|
| `If1` | if | Detecta presença de arquivo |
| `HTTP Request6` | httpRequest | Envia imagem pra análise (Vision) |
| `PDF Extractor` | httpRequest | Extrai texto de PDF |
| `Code` | code | Processa texto extraído |
| `Code1` | code | Formatação adicional |

### Limitação de teste

Mesma limitação do áudio: **Watson NÃO consegue enviar imagem/PDF real via webhook simulado.** O payload precisa de MEDIA_ID real da Meta API.

---

## 2. Estratégia de teste

### O que Watson PODE testar:
1. Verificar nós de OCR/PDF no workflow (análise estática)
2. Verificar execuções passadas com imagem/PDF
3. Verificar se texto extraído foi processado corretamente
4. Verificar configuração do Vision API / PDF Extractor

### O que Watson NÃO pode testar:
1. Enviar imagem real com nota fiscal
2. Enviar PDF com extrato bancário
3. Qualidade do OCR em diferentes tipos de imagem

---

## 3. Algoritmo de execução

```
PASSO 1 — ANÁLISE ESTÁTICA
  1.1  GET /api/v1/workflows/ImW2P52iyCS0bGbQ (Fix Conflito v2)
  1.2  Verificar nós If1, HTTP Request6, PDF Extractor, Code
  1.3  Verificar URLs de API configuradas (Vision, PDF extractor)

PASSO 2 — ANÁLISE DE EXECUÇÕES PASSADAS
  2.1  Buscar execuções do Fix Conflito v2 que passaram por If1
  2.2  Verificar success/error

PASSO 3 — ANÁLISE DE LOGS
  3.1  Buscar log_users_messages com evidência de imagem/PDF processado

PASSO 4 — REGISTRAR
```

---

## 4. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Nós de OCR existem | If1, HTTP Request6, PDF Extractor configurados | Ausentes |
| 2 | Vision API configurada | URL válida, auth presente | Mal configurado |
| 3 | Execuções passadas | Existem execuções com imagem que deram success | Todas error |
| 4 | Texto extraído processado | Após OCR, texto vai pro classificador normalmente | Para no OCR |

---

## 5. Protocolo de diagnóstico de erros

```
CAMADA 1 — DETECÇÃO: If1 não detectou arquivo?
CAMADA 2 — DOWNLOAD: Arquivo não baixou da Meta API?
CAMADA 3 — OCR/VISION: API de análise falhou?
CAMADA 4 — EXTRAÇÃO: Code node não extraiu texto?
CAMADA 5 — DOWNSTREAM: Texto extraído não foi processado?
```

---

## 6. Testes

**🟢 Quick (2 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| OCR-Q1 | Análise estática | Nós de OCR existem e estão conectados |
| OCR-Q2 | Execuções passadas | Alguma execução com imagem deu success |

**🟡 Broad (Quick + 3 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| OCR-B1 | PDF Extractor config | URL, auth, formato de resposta |
| OCR-B2 | Vision API config | Modelo, prompt de extração |
| OCR-B3 | Erros de OCR | Execuções com error nos nós de OCR |

**🔴 Complete (Broad + 2 testes):**

| ID | Input | Verificação |
|----|-------|-------------|
| OCR-C1 | Payload simulado de imagem | Switch roteia? If1 detecta? (vai falhar no download) |
| OCR-C2 | Verificar integração financeira | Se imagem tem valor → cria gasto? |

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Logar "fonte=imagem" ou "fonte=pdf" no log | Rastreio de mídia |
| Criar test suite com imagens de exemplo | Teste end-to-end de OCR |
| Fallback se OCR falhar | Avisar user que não conseguiu ler |
