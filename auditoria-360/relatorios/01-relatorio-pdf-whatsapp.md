# Metodologia de Auditoria — Relatório PDF via WhatsApp

**Funcionalidade:** `relatorios/01-relatorio-pdf-whatsapp`
**Versão:** 1.0.0
**Testável via WhatsApp:** ✅ SIM

---

## 1. Mapa do sistema

### Caminho

```
WhatsApp: "gera meu relatório" → Fix Conflito v2
  → Escolher Branch → gerar_relatorio
    → prompt_rel → AI Agent → Tool: gerar_relatorio (httpRequestTool)
      → Report Unificado (webhook: webhook-report / relatorio-semanal / relatorio-mensal)
        → buscar-perfil (Supabase profiles)
        → buscar-gastos (Supabase spent)
        → gerar-html (Code — monta HTML do relatório)
        → gotenberg-pdf (httpRequest — converte HTML→PDF via Gotenberg)
        → upload-pdf-whatsapp (httpRequest — upload pra Meta API)
        → enviar-whatsapp (httpRequest — envia documento)
        → resposta-sucesso (set)
    → IA responde "Seu relatório está sendo gerado 🔃"
```

### Workflows

| Workflow | ID | Papel |
|----------|----|-------|
| Fix Conflito v2 | `ImW2P52iyCS0bGbQ` | Branch gerar_relatorio |
| Report Unificado | `0erjX5QpI9IJEmdi` | Gera HTML → PDF → envia WhatsApp |

### Nós do Report Unificado (`0erjX5QpI9IJEmdi`)

| Nó | Função |
|----|--------|
| `webhook-report` | Recebe pedido de relatório |
| `relatorio-semanal` / `relatorio-mensal` | Webhooks de schedule |
| `buscar-perfil` | GET profiles |
| `buscar-gastos` | GET spent (dados financeiros) |
| `gerar-html` | Code: monta HTML do relatório |
| `gotenberg-pdf` | POST Gotenberg: HTML → PDF |
| `upload-pdf-whatsapp` | POST Meta API: upload PDF |
| `enviar-whatsapp` | POST Meta API: envia como documento |
| `trigger-semanal` / `trigger-mensal1` | Schedule automático |
| `Create a row1` | Log no log_total |

### Tabela: `reports`

Tabela existe mas estava vazia no diagnóstico. Pode ser usada pra armazenar relatórios gerados.

---

## 2. Algoritmo de execução

```
PASSO 1 — SNAPSHOT ANTES
  1.1  Último log_id → LAST_LOG_ID
  1.2  Verificar execuções Report Unificado → EXEC_ANTES
  1.3  Verificar log_total por acao=relatorio_enviado → REL_ANTES

PASSO 2 — ENVIAR "gera meu relatório do mês"

PASSO 3 — POLLAR RESPOSTA
  → IA responde "Seu relatório está sendo gerado 🔃"

PASSO 4 — ESPERAR (relatório é async — Gotenberg + upload + envio)
  → Esperar 30-60s

PASSO 5 — VERIFICAR
  5.1  Execução do Report Unificado: status=success?
  5.2  log_total: nova entrada acao=relatorio_enviado?
  5.3  reports: novo registro? (se tabela for usada)
  5.4  Watson NÃO pode verificar se PDF chegou no WhatsApp

PASSO 6 — REGISTRAR
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | IA aceita pedido | "relatório está sendo gerado" | Erro |
| 2 | Report Unificado executou | Nova execução com status=success | Error ou sem execução |
| 3 | Dados corretos | buscar-gastos retorna dados do user | Dados de outro user |
| 4 | Log registrado | log_total: relatorio_enviado | Sem log |

---

## 4. Protocolo de diagnóstico

```
CAMADA 1 — CLASSIFICADOR: Foi pra branch gerar_relatorio?
CAMADA 2 — AI AGENT: Chamou tool gerar_relatorio?
CAMADA 3 — REPORT UNIFICADO: Webhook executou?
CAMADA 4 — BUSCA DADOS: buscar-perfil e buscar-gastos retornaram dados?
CAMADA 5 — HTML: gerar-html produziu HTML válido?
CAMADA 6 — GOTENBERG: PDF foi gerado? (gotenberg-pdf status)
CAMADA 7 — UPLOAD: PDF foi uploaded pra Meta API?
CAMADA 8 — ENVIO: WhatsApp recebeu o documento?
```

---

## 5. Testes

**🟢 Quick (2):**

| ID | Input | Verificação |
|----|-------|-------------|
| REL-Q1 | "gera meu relatório do mês" | IA aceita. Report Unificado executou. |
| REL-Q2 | "relatório da semana" | IA aceita. Execução success. |

**🟡 Broad (+4):**

| ID | Input | O que valida |
|----|-------|-------------|
| REL-B1 | "relatório de fevereiro" | Período específico |
| REL-B2 | Verificar log_total | relatorio_enviado apareceu |
| REL-B3 | Verificar execução Report Unificado | Todos os nós executaram sem erro |
| REL-B4 | Schedule automático | trigger-semanal/mensal está ativo |

**🔴 Complete (+3):**

| ID | Input | O que valida |
|----|-------|-------------|
| REL-C1 | Relatório com gastos=0 | Funciona sem dados? |
| REL-C2 | Relatório de período muito longo | Mês inteiro com 50+ registros |
| REL-C3 | Verificar Gotenberg | Container rodando, PDF gerado |

---

## 6. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Usar tabela reports pra armazenar relatórios gerados | Histórico auditável |
| Logar URL do PDF no log_total | Verificar geração sem acessar WhatsApp |
