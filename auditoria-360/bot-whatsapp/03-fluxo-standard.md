# Metodologia de Auditoria — Fluxo Standard

**Funcionalidade:** `bot-whatsapp/03-fluxo-standard`
**Versão:** 1.0.0

---

## 1. Mapa do sistema

### Caminho

```
Main → Switch1 (status do user) → If3 (plano)
  → Standard User2 / Standard User3 (httpRequest)
    → Resposta limitada (sem AI Agent completo)
    → Pode incluir nudge para upgrade
```

### Diferença Premium vs Standard

| Aspecto | Premium | Standard |
|---------|---------|----------|
| AI Agent | ✅ GPT-4.1-mini com tools | ❌ Sem AI Agent completo |
| Financeiro CRUD | ✅ Criar/editar/excluir gastos | ⚠️ Limitado ou ausente |
| Agenda CRUD | ✅ Completo | ⚠️ Limitado |
| Áudio/Imagem | ✅ Whisper + OCR | ❓ Verificar |
| Relatórios PDF | ✅ Gotenberg | ❌ Pode não ter |

### Nós no Main

| Nó | Tipo | Função |
|----|------|--------|
| `Standard User2` | httpRequest | Processa mensagem Standard |
| `Standard User3` | httpRequest | Alternativa Standard |
| Nudge nodes | whatsApp | Envia sugestão de upgrade |

---

## 2. Algoritmo de execução

```
PASSO 1 — Verificar plano do user de teste
  Se é Premium: NÃO consegue testar Standard com esse user
  Opção A: Mudar plano temporariamente (risco)
  Opção B: Usar outro user de teste com plano Standard
  Opção C: Testar apenas verificando o código do workflow

PASSO 2 — Se possível testar: enviar mensagem

PASSO 3 — Verificar que NÃO roteou pro Fix Conflito v2

PASSO 4 — Verificar resposta limitada
```

---

## 3. Critérios de PASS/FAIL

| # | Critério | PASS | FAIL |
|---|----------|------|------|
| 1 | Não roteou Premium | Sem execução do Fix Conflito v2 | Executou Fix Conflito |
| 2 | Resposta entregue | ai_message no log | Sem resposta |
| 3 | Funcionalidades limitadas | NÃO criou gasto/evento (se bloqueado pra Standard) | Criou como se fosse Premium |
| 4 | Nudge para upgrade | Menciona upgrade em algum momento | — (não é FAIL se não menciona) |

---

## 4. Protocolo de diagnóstico de erros

Mesmo protocolo base. Camadas específicas:
```
CAMADA 1 — PLANO: profiles.plan_type está correto?
CAMADA 2 — SWITCH: If3 roteou pra Standard User?
CAMADA 3 — STANDARD USER: httpRequest retornou resposta?
CAMADA 4 — LIMITES: User Standard acessou funcionalidade Premium?
```

---

## 5. Testes

**🟢 Quick (2 testes):**

| ID | Input | Esperado |
|----|-------|----------|
| STD-Q1 | "oi" (user Standard) | Resposta genérica, sem AI Agent Premium |
| STD-Q2 | "gastei 50 no almoço" (user Standard) | Limitado: não cria gasto OU cria com funcionalidade básica |

**🟡 Broad (Quick + 4 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| STD-B1 | "minha agenda" | Funciona no Standard? |
| STD-B2 | "gera relatório" | Bloqueado ou funciona? |
| STD-B3 | Enviar áudio | Transcreve no Standard? |
| STD-B4 | "quero o premium" | Nudge / link de upgrade? |

**🔴 Complete (Broad + 3 testes):**

| ID | Input | O que valida |
|----|-------|-------------|
| STD-C1 | Todas as funcionalidades Premium | Documentar quais funcionam e quais não no Standard |
| STD-C2 | Rate limiting | Mesmo do Premium? Diferente? |
| STD-C3 | Verificar execuções N8N | Somente Main, sem Fix Conflito v2 |

---

## 6. Limitações de teste

| Limitação | Impacto |
|-----------|---------|
| User de teste (Luiz Felipe) é Premium | Precisa de user Standard pra testar |
| Se mudar plano do user, afeta outros testes | Risco de regressão |
| Fluxo Standard pode variar por versão | Documentar comportamento observado |

---

## 7. Melhorias sugeridas

| O que | Impacto |
|-------|---------|
| Criar user de teste Standard dedicado | Testes isolados por plano |
| Documentar quais features são Standard vs Premium | Clareza para auditoria |
