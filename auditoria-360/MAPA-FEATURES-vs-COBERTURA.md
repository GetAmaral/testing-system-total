# Mapa de Features vs Cobertura da Auditoria 360°

**Data:** 2026-03-18
**Fonte:** [system-analise/features](https://github.com/GetAmaral/system-analise/tree/master/features)
**Total:** 7 categorias, 29 features

---

## Legenda

| Símbolo | Significado |
|---------|-------------|
| ✅ | Testado e verificado no banco real |
| ⚠️ | Testado parcialmente (só resposta da IA, ou só parte da feature) |
| ❌ | Não testado |
| 🔬 | A explorar na próxima fase |

---

## 1. FINANCEIRO (4 features)

```
financeiro/
├── 01-despesas-receitas/          ⚠️ PARCIAL
│   ├── Criar gasto                ✅ Verificado no banco (spent)
│   ├── Criar receita              ✅ Verificado no banco (spent)
│   ├── Editar valor               ⚠️ Funciona async — verificação precisa de mais tempo
│   ├── Editar nome                ⚠️ Funciona async — idem
│   ├── Editar categoria           ⚠️ Funciona async — idem + divergência IA vs banco
│   ├── Excluir gasto              ✅ Verificado (contagem antes/depois)
│   ├── Excluir múltiplos          ❌ Não testado
│   ├── Buscar por período         ⚠️ Só resposta da IA, não cruzou com banco
│   ├── Buscar por categoria       ❌ Não testado com verificação real
│   ├── Categorias predefinidas    🔬 11 categorias — verificar se IA classifica correto
│   ├── type_spent (Fixo/Variavel) 🔬 Nunca verificado
│   └── RLS por usuario            ❌ Não testado isolamento entre users
│
├── 02-limites-categoria/          ❌ NÃO TESTADO
│   ├── Definir limite             🔬
│   ├── Alertas de ultrapassagem   🔬
│   └── Tabela category_limits     🔬
│
├── 03-metas-financeiras/          ❌ NÃO TESTADO
│   ├── Criar meta                 🔬
│   ├── Acompanhar progresso       🔬
│   └── Notificações de meta       🔬
│
└── 04-limite-mensal-gasto/        ❌ NÃO TESTADO
    ├── Definir limite mensal      🔬
    ├── Alerta ao atingir          🔬
    └── Resumo mensal              🔬
```

**Cobertura: 1/4 features (parcial)**

---

## 2. AGENDA (8 features)

```
agenda/
├── 01-agendamento-proprio/        ⚠️ PARCIAL
│   ├── Criar evento pontual       ✅ Verificado no calendar
│   ├── Criar com horário          ✅ start_event correto
│   ├── Criar sem horário          ❌ Não testado
│   ├── end_event padrão 30min     🔬 Existe mas não validamos se é correto
│   ├── compromisso_tipo           🔬 compromisso vs lembrete — regra?
│   └── connect_google             ⚠️ Vemos o campo mas não verificamos Google
│
├── 02-consulta-compromissos/      ⚠️ PARCIAL
│   ├── Agenda do dia              ⚠️ Só resposta da IA
│   ├── Agenda da semana           ⚠️ Só resposta da IA
│   ├── Próximos N dias            ❌ Não testado com verificação
│   └── Eventos de data específica ❌ Não testado
│
├── 03-modificacao-compromissos/   ⚠️ PARCIAL
│   ├── Editar horário             ❌ Não testado
│   ├── Editar data                ✅ Funciona async (T6 confirmou)
│   ├── Renomear evento            ❌ Bateria 04 mostrou que deleta — retestar
│   ├── end_event acompanha start  ❌ BUG CONFIRMADO: end_event não atualiza
│   └── Editar descrição           ❌ Não testado
│
├── 04-exclusao-compromissos/      ⚠️ PARCIAL
│   ├── Excluir pontual            ✅ Verificado (T5)
│   ├── Excluir recorrente         ❌ Não testado (A-200 mostrou falhas)
│   ├── Excluir múltiplos          ❌ Não testado
│   └── Excluir por data           ❌ Não testado
│
├── 05-sync-google-calendar/       ❌ EXCLUÍDO DA AUDITORIA
│   └── (sync bidirecional ok)     — Não precisa testar por decisão do PO
│
├── 06-lembretes-recorrentes/      ⚠️ PARCIAL
│   ├── Criar recorrente           ❌ T7 pediu confirmação, não criou
│   ├── rrule correto              🔬 BYDAY, FREQ — nunca verificado
│   ├── Duplicação                 🔬 Bug conhecido de duplicação
│   ├── Cancelar recorrente        ❌ Não testado
│   └── Editar recorrente          ❌ Não testado
│
├── 07-agenda-diaria-automatica/   ❌ NÃO TESTADO
│   ├── Envio automático matinal   🔬
│   ├── Horário configurável       🔬
│   └── Apenas Premium             🔬
│
└── 08-vip-calendar/               ❌ NÃO TESTADO
    ├── Calendar por telefone      🔬
    ├── Sem autenticação           🔬
    └── Tabela calendar_vip        🔬
```

**Cobertura: 3/8 features (parcial)**

---

## 3. BOT-WHATSAPP (6 features)

```
bot-whatsapp/
├── 01-roteador-principal/         ⚠️ PARCIAL
│   ├── Classificação de intenção  ⚠️ Testamos indiretamente (gastos, agenda, fora de escopo)
│   ├── Roteamento correto         🔬 Qual branch o classificador escolheu?
│   ├── Fallback/erro              ❌ Não testado
│   └── Rate limiting              ❌ Não testado
│
├── 02-fluxo-premium/              ⚠️ PARCIAL
│   ├── AI Agent responde          ✅ Todas as respostas vieram do AI Agent
│   ├── Contexto multi-turno       ⚠️ A-200 testou "e amanhã?" mas sem verificação
│   ├── Prompt system              🔬 Conteúdo do prompt vs comportamento
│   └── Tool calling (N8N tools)   🔬 Quais tools o agent chamou?
│
├── 03-fluxo-standard/             ❌ NÃO TESTADO
│   ├── Respostas sem AI           🔬
│   ├── Limite de funcionalidades  🔬
│   └── Nudge para upgrade         🔬
│
├── 04-transcricao-audio/          ❌ NÃO TESTADO
│   ├── Receber áudio WhatsApp     🔬
│   ├── Transcrever (Whisper/etc)  🔬
│   └── Processar como texto       🔬
│
├── 05-ocr-imagem-pdf/             ❌ NÃO TESTADO
│   ├── Receber imagem             🔬
│   ├── OCR / visão                🔬
│   └── Extrair dados financeiros  🔬
│
└── 06-bot-guard/                  ❌ NÃO TESTADO
    ├── Anti-loop                  🔬
    ├── Anti-spam                  🔬
    ├── Bloqueio temporário        🔬
    └── bot_blocks + bot_events    🔬
```

**Cobertura: 1/6 features (parcial)**

---

## 4. AUTENTICAÇÃO (5 features)

```
autenticacao/
├── 01-login-otp/                  ❌ NÃO TESTADO
│   ├── Email + password           🔬
│   ├── OTP code                   🔬
│   └── Sessão                     🔬
│
├── 02-google-oauth/               ❌ NÃO TESTADO
│   ├── OAuth flow                 🔬
│   ├── Token storage              🔬
│   └── Refresh token              🔬
│
├── 03-2fa-legado/                 ❌ NÃO TESTADO
│   ├── two_factor_sessions        🔬
│   └── pending_2fa_sessions       🔬
│
├── 04-rbac-planos/                ❌ NÃO TESTADO
│   ├── Premium vs Standard        🔬 Testamos só Premium
│   ├── Verificação de plano       🔬
│   └── Bloqueio de features       🔬
│
└── 05-gestao-conta/               ❌ NÃO TESTADO
    ├── Alterar dados              🔬
    ├── Excluir conta              🔬
    └── LGPD                       🔬
```

**Cobertura: 0/5 features**

---

## 5. INVESTIMENTOS (1 feature)

```
investimentos/
└── 01-portfolio/                  ❌ NÃO TESTADO
    ├── Tabela investments         🔬 Existe no banco mas sem workflow
    ├── CRUD investimentos         🔬
    └── Categorias (CDB, etc)     🔬
```

**Cobertura: 0/1 features**

---

## 6. PAGAMENTOS (3 features)

```
pagamentos/
├── 01-hotmart-webhook/            ❌ NÃO TESTADO
│   ├── Webhook de compra          🔬
│   ├── Ativação de plano          🔬
│   └── Webhook de cancelamento    🔬
│
├── 02-checkout-planos/            ❌ NÃO TESTADO
│   ├── Página de checkout         🔬
│   ├── Short links                🔬
│   └── Redirecionamento           🔬
│
└── 03-gestao-assinatura/          ❌ NÃO TESTADO
    ├── Cancelar plano             🔬
    ├── Reativar plano             🔬
    └── Verificar status           🔬
```

**Cobertura: 0/3 features**

---

## 7. RELATÓRIOS (2 features)

```
relatorios/
├── 01-relatorio-pdf-whatsapp/     ⚠️ PARCIAL
│   ├── Gerar relatório mensal     ⚠️ A-200 testou, IA disse "gerando" — sem verificação
│   ├── Gerar por período          ⚠️ Idem
│   ├── PDF gerado (Gotenberg)     ❌ Não verificamos se PDF foi gerado
│   └── Envio via WhatsApp         ❌ Não verificamos entrega
│
└── 02-export-frontend/            ❌ NÃO TESTADO
    ├── Export PDF frontend        🔬
    └── Export Excel               🔬
```

**Cobertura: 0/2 features (só resposta da IA, sem verificação)**

---

## Resumo de Cobertura

| Categoria | Features | Testadas | Cobertura |
|-----------|----------|----------|-----------|
| **Financeiro** | 4 | 1 parcial | **~10%** |
| **Agenda** | 8 | 3 parciais | **~15%** |
| **Bot WhatsApp** | 6 | 1 parcial | **~5%** |
| **Autenticação** | 5 | 0 | **0%** |
| **Investimentos** | 1 | 0 | **0%** |
| **Pagamentos** | 3 | 0 | **0%** |
| **Relatórios** | 2 | 0 | **0%** |
| **TOTAL** | **29** | **5 parciais** | **~6%** |

---

## Estrutura proposta para auditoria completa

Cada feature deve ter seu diretório com testes verificados:

```
auditoria-360/
├── MAPA-FEATURES-vs-COBERTURA.md          ← este arquivo
│
├── financeiro/
│   ├── 01-despesas-receitas.md            🔬
│   ├── 02-limites-categoria.md            🔬
│   ├── 03-metas-financeiras.md            🔬
│   └── 04-limite-mensal-gasto.md          🔬
│
├── agenda/
│   ├── 01-agendamento-proprio.md          🔬
│   ├── 02-consulta-compromissos.md        🔬
│   ├── 03-modificacao-compromissos.md     🔬
│   ├── 04-exclusao-compromissos.md        🔬
│   ├── 05-sync-google-calendar.md         — (excluído)
│   ├── 06-lembretes-recorrentes.md        🔬
│   ├── 07-agenda-diaria-automatica.md     🔬
│   └── 08-vip-calendar.md                 🔬
│
├── bot-whatsapp/
│   ├── 01-roteador-principal.md           🔬
│   ├── 02-fluxo-premium.md               🔬
│   ├── 03-fluxo-standard.md              🔬
│   ├── 04-transcricao-audio.md            🔬
│   ├── 05-ocr-imagem-pdf.md              🔬
│   └── 06-bot-guard.md                    🔬
│
├── autenticacao/
│   ├── 01-login-otp.md                    🔬
│   ├── 02-google-oauth.md                 🔬
│   ├── 03-2fa-legado.md                   🔬
│   ├── 04-rbac-planos.md                  🔬
│   └── 05-gestao-conta.md                 🔬
│
├── investimentos/
│   └── 01-portfolio.md                    🔬
│
├── pagamentos/
│   ├── 01-hotmart-webhook.md              🔬
│   ├── 02-checkout-planos.md              🔬
│   └── 03-gestao-assinatura.md            🔬
│
└── relatorios/
    ├── 01-relatorio-pdf-whatsapp.md       🔬
    └── 02-export-frontend.md              🔬
```

Cada `.md` conterá:
- Resumo da feature (do system-analise)
- Testes executados com verificação real
- Bugs encontrados
- Status: ✅ Auditado | ⚠️ Parcial | ❌ Pendente

---

*Mapa gerado por @testador (Watson)*
