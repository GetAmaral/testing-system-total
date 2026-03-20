# 15 — Correlação: Squad Auditor-Real × Metodologia da Aviação

> Análise detalhada de como o squad auditor-real já implementa (ou pode implementar)
> cada conceito da segurança da aviação.

---

## 1. Visão Geral

O squad **auditor-real** é um sistema multi-agente de auditoria que analisa interações reais de usuários no Total Assistente. Sua estrutura já reflete, de forma notável, vários princípios da aviação — muitas vezes sem referência explícita a eles. Este documento mapeia cada paralelo e identifica oportunidades de fortalecimento.

---

## 2. Tabela de Correlação Completa

| Conceito Aviação | Implementação no Squad Auditor-Real | Força | Oportunidade |
|-----------------|--------------------------------------|-------|-------------|
| **Swiss Cheese** | Deep-Agent investiga 6 camadas (webhook→routing→extração→LLM→ação→resposta) | ⭐⭐⭐⭐⭐ | Já implementa análise multicamada |
| **CRM** | 5 agentes especializados com comunicação orquestrada pelo Commander | ⭐⭐⭐⭐ | Adicionar briefing/debriefing formal entre agentes |
| **TEM** | Classificador identifica ameaças, erros e estados indesejados | ⭐⭐⭐⭐ | Formalizar taxonomia TEM nos tipos de problema |
| **LOSA** | Auditoria de operações reais em condições normais (não simuladas) | ⭐⭐⭐⭐⭐ | Essência do squad — observar operação real |
| **Just Culture** | Foco em aprender, não culpar. Read-only por design. | ⭐⭐⭐⭐ | Adicionar classificação explícita: erro/risco/imprudência |
| **HFACS** | Classificador usa 9 tipos + 4 severidades + 5 componentes | ⭐⭐⭐⭐ | Mapear para os 4 níveis HFACS |
| **SMS** | Estrutura organizacional com política, gestão de risco, monitoramento | ⭐⭐⭐ | Formalizar os 4 pilares |
| **Checklists** | `readonly-guardrails.md` e `data-completeness.md` | ⭐⭐⭐⭐⭐ | Já implementa — expandir para mais fases |
| **FDM/Black Box** | Coleta dados de 6+ fontes para análise pós-evento | ⭐⭐⭐⭐ | Propor `execution_log` como FDM proativo |
| **ASAP/ASRS** | — | ⭐ | Criar sistema de reporte voluntário para erros |
| **RCA** | Deep-Agent faz análise de causa raiz em 6 camadas | ⭐⭐⭐⭐⭐ | Adicionar 5-Why formal e Fishbone |
| **SOPs** | Agentes seguem procedimentos detalhados em seus prompts | ⭐⭐⭐⭐ | Versionamento e revisão periódica dos SOPs |
| **Sterile Cockpit** | Guardrails de 7 camadas bloqueiam atividades não essenciais | ⭐⭐⭐⭐⭐ | Princípio equivalente implementado |
| **Kaizen/PDCA** | Recomendações de melhoria por prioridade | ⭐⭐⭐ | Formalizar ciclo PDCA nas iterações |
| **MRM (Dirty Dozen)** | — | ⭐ | Mapear os 12 fatores para erros de sistema |

---

## 3. Análise Detalhada por Conceito

### 3.1 Swiss Cheese ↔ Deep-Agent (6 Camadas)

**Na aviação:** Acidentes resultam do alinhamento de falhas em múltiplas camadas de defesa.

**No squad:** O Deep-Agent (Pathfinder) investiga exatamente 6 camadas, espelhando a lógica do Swiss Cheese:

| Camada Aviação | Camada Deep-Agent | Equivalência |
|---------------|-------------------|-------------|
| Barreira de engenharia | **L1 — Recepção Webhook** | Mensagem chegou ao sistema? Formato correto? |
| Projeto do espaço aéreo | **L2 — Roteamento** | State machine correta? Workflow certo selecionado? |
| Controle de tráfego | **L3 — Extração de Dados** | Texto/áudio parseado corretamente? |
| Treinamento/licenciamento | **L4 — Processamento LLM** | System prompt adequado? Tool certa selecionada? |
| SOPs/Checklists | **L5 — Execução da Ação** | Query executou? Dados persistidos? |
| Verificação final | **L6 — Geração de Resposta** | Mensagem formatada e enviada corretamente? |

**Força:** O squad já entende intuitivamente que falhas são multicausais e investiga camada por camada.

**Oportunidade:** Formalizar a análise de "condições latentes" — além de encontrar onde falhou, investigar que condições organizacionais/sistêmicas permitiram a falha.

---

### 3.2 CRM ↔ Orquestração Multi-Agente

**Na aviação:** Equipe coordenada onde cada membro tem papel definido, comunicação é padronizada, e hierarquia não bloqueia informação crítica.

**No squad:**

| Papel CRM | Agente Equivalente | Função |
|-----------|-------------------|--------|
| Capitão (decisor) | **Commander (Argus)** | Orquestra, decide, consolida |
| Copiloto (monitora) | **Avaliador (Judge)** | Avalia qualidade, atribui vereditos |
| Engenheiro de Voo (sistemas) | **Coletor (Reaper)** | Coleta dados de 6+ fontes |
| Despachante (planejamento) | **Classificador (Ranker)** | Prioriza, detecta padrões |
| Investigador de acidentes | **Deep-Agent (Pathfinder)** | Análise de causa raiz |

**Força:** Separação clara de responsabilidades com especialização.

**Oportunidade:**
- Implementar **briefings formais** (Commander define escopo e expectativas antes de delegar)
- Implementar **debriefings** (consolidação de lições aprendidas após cada auditoria)
- Garantir que qualquer agente possa "escalar" para o Commander se encontrar algo inesperado (assertividade sem hierarquia rígida)

---

### 3.3 LOSA ↔ Auditoria de Operações Reais

**Na aviação:** LOSA observa voos normais, não check-rides. Dados anônimos, não-punitivos, coletados por pares.

**No squad:** O auditor-real analisa interações **reais** de usuários **em condições normais de operação**. Não testa cenários artificiais — observa o que realmente aconteceu.

| Característica LOSA | Implementação no Squad |
|--------------------|----------------------|
| Observação de operações normais | ✅ Analisa conversas reais de produção |
| Dados anônimos | ⚠️ Parcial — dados são por usuário, mas outputs não vazam dados sensíveis |
| Não-punitivo | ✅ Read-only, sem ações de enforcement |
| Observadores treinados | ✅ Agentes com personas especializadas e critérios objetivos |
| Análise sistemática | ✅ Dimensões ponderadas, scores calculados |
| Feedback baseado em dados | ✅ Rankings, relatórios, recomendações priorizadas |

**Força:** O squad É essencialmente um LOSA digital para sistemas de IA conversacional.

---

### 3.4 Just Culture ↔ Read-Only e Foco em Aprendizado

**Na aviação:** Consolar erros honestos, orientar comportamentos de risco, punir apenas conduta imprudente.

**No squad:** O design read-only é uma implementação natural de Just Culture:
- Não "pune" o sistema (não modifica nada)
- Foco exclusivo em entender e recomendar (aprender)
- Guardrails de 7 camadas garantem que a auditoria não cause dano

**Oportunidade:** O Classificador poderia adotar explicitamente as 3 categorias de Marx:

| Categoria Marx | Aplicação no Squad |
|---------------|-------------------|
| **Erro do sistema** (honest mistake) | Bug de código, falha de integração → consolar e corrigir |
| **Comportamento de risco** (at-risk) | Prompt inadequado, logging ausente → orientar e ajustar |
| **Negligência** (reckless) | Ausência deliberada de tratamento de erro → flag de alta prioridade |

---

### 3.5 HFACS ↔ Sistema de Classificação do Ranker

**Na aviação:** 19 categorias em 4 níveis, do ato inseguro à influência organizacional.

**No squad:** O Classificador usa:
- 9 tipos de problema
- 4 níveis de severidade
- 5 componentes
- 3 níveis de frequência
- 5 categorias de impacto

**Mapeamento proposto para os 4 níveis HFACS:**

| Nível HFACS | Equivalente no Squad | Exemplo |
|------------|---------------------|---------|
| **Atos inseguros** | Erros do LLM, ações incorretas | "IA selecionou tool errada" |
| **Precondições** | Ambiente do sistema | "Redis TTL expirou, contexto perdido" |
| **Supervisão insegura** | Gaps de monitoramento | "Standard workflow sem logging" |
| **Influências organizacionais** | Decisões de arquitetura | "Decisão de não logar workflow Standard" |

---

### 3.6 Checklists ↔ Guardrails e Data-Completeness

**Na aviação:** Checklists nasceram porque o B-17 era "complexo demais para a memória."

**No squad:** `readonly-guardrails.md` e `data-completeness.md` são exatamente checklists de aviação:

**readonly-guardrails.md (equivale a "Before Takeoff Checklist"):**
- ☐ Query começa com SELECT?
- ☐ Sem palavras de mutação?
- ☐ Comando na whitelist?
- ☐ Service_role justificado?
- ☐ Output no diretório correto?
- ☐ Nenhuma mensagem sendo enviada?
- ☐ Nenhum dado sensível exposto?

**data-completeness.md (equivale a "After Landing Checklist"):**
- ☐ Todas as 6 fontes consultadas?
- ☐ Cross-references feitos?
- ☐ Órfãos detectados?
- ☐ Cobertura ≥95%?

**Força:** Implementação exemplar. Os checklists são Do-Confirm (agente executa, depois verifica).

---

### 3.7 FDM ↔ execution_log + Coleta Proativa

**Na aviação:** FDM analisa dados de CADA voo normal, não apenas acidentes.

**No squad:** O `execution_log` (tabela nova no Supabase) é conceitualmente equivalente a um FDM:
- Captura cada processamento de mensagem
- Registra classificação, ação, sucesso/falha, erro
- Permite análise de tendências sobre TODA a operação

**Gap crítico identificado pelo squad:** O workflow Standard não tem logging nenhum. É como um avião sem FDR — se algo acontecer, não há dados para investigar.

**Recomendação alinhada com aviação:** Assim como ICAO Annex 6 mandatou FDM para TODAS as companhias, TODOS os workflows devem ter logging obrigatório.

---

### 3.8 RCA ↔ Deep-Agent Investigation

**Na aviação:** 5-Why, Fishbone, Fault Tree Analysis para encontrar causa raiz.

**No squad:** O Deep-Agent já faz análise de causa raiz em 6 camadas, mas poderia formalizar:

**5-Why proposto:**
```
Usuário não recebeu resposta
  └── Por quê? Workflow Standard não enviou mensagem
       └── Por quê? Tool call do LLM falhou
            └── Por quê? Prompt não cobria o caso de uso
                 └── Por quê? Não há processo de revisão de prompts
                      └── CAUSA RAIZ: ausência de governança de prompts
```

**Fishbone proposto para erros do sistema:**
```
         Humano (Prompt Design)
        /
LLM (Modelo/Config) ──── FALHA ──── Método (SOP do Workflow)
        \                               /
         Dados (Redis/Supabase) ──── Ambiente (Infraestrutura)
                                        \
                                         Gestão (Decisões de Arquitetura)
```

---

### 3.9 Sterile Cockpit ↔ Guardrails de 7 Camadas

**Na aviação:** Durante fases críticas, ZERO atividades não essenciais.

**No squad:** Os guardrails de 7 camadas implementam exatamente este princípio:

| Camada | Função | Equivalente Aviação |
|--------|--------|-------------------|
| 1 — Declaração do agente | Cada agente declara READ-ONLY como regra suprema | "Sterile cockpit declarado" |
| 2 — Restrição Supabase | Apenas SELECT permitido | "Apenas ações essenciais" |
| 3 — Restrição SSH | Whitelist de comandos | "Comandos autorizados apenas" |
| 4 — Proibição de envio | WhatsApp, N8N webhooks, email bloqueados | "Nenhuma transmissão não essencial" |
| 5 — Lock de diretório | Escrita apenas em output/ | "Foco operacional" |
| 6 — Gate de auto-verificação | Checklist mental antes de CADA operação | "Cross-check before action" |
| 7 — Proteção de privacidade | Dados sensíveis bloqueados | "Segurança de informação" |

---

## 4. O Que Falta — Gaps vs. Aviação

### 4.1 Sistema de Reporte Voluntário (ASAP/ASRS)
**Na aviação:** Pilotos reportam erros voluntariamente sem medo.
**No squad:** Não existe equivalente. Os "usuários" do sistema (workflows, LLMs) não "reportam" suas falhas.
**Proposta:** Implementar um canal onde desenvolvedores/operadores do Total Assistente possam reportar problemas observados sem formalidade, alimentando o auditor.

### 4.2 Dirty Dozen para IA Conversacional
**Na aviação:** 12 precondições de erro humano em manutenção.
**Proposta — "Dirty Dozen" para Sistemas de IA:**

| # | Fator | Equivalente IA |
|---|-------|---------------|
| 1 | Falta de comunicação | Prompt ambíguo, contexto perdido entre workflows |
| 2 | Distração | Informação irrelevante poluindo contexto |
| 3 | Falta de recursos | Token limit atingido, timeout de API |
| 4 | Estresse | Alta concorrência, rate limiting |
| 5 | Complacência | "Sempre funcionou" — sem monitoramento |
| 6 | Falta de trabalho em equipe | Workflows isolados sem compartilhar estado |
| 7 | Pressão | Resposta forçada mesmo sem dados suficientes |
| 8 | Falta de consciência | Sem logging, sem observabilidade |
| 9 | Falta de conhecimento | Prompt sem contexto suficiente do domínio |
| 10 | Fadiga | Degradação por acúmulo de contexto/memória |
| 11 | Falta de assertividade | Sistema não consegue dizer "não sei" |
| 12 | Normas | Workarounds que se tornaram padrão |

### 4.3 Ciclo PDCA Formalizado
**Na aviação:** Plan-Do-Check-Act contínuo.
**Proposta para o squad:**

```
PLAN: Commander define escopo e métricas da auditoria
  ↓
DO: Coletor + Avaliador + Classificador executam
  ↓
CHECK: Commander consolida e compara com auditorias anteriores
  ↓
ACT: Recomendações implementadas → próxima auditoria verifica
  ↓
[Ciclo contínuo]
```

---

## 5. Conclusão — Onde o Squad Já Está vs. Onde Pode Chegar

### O squad auditor-real já implementa (com força):
- ✅ Análise multicamada (Swiss Cheese / Deep-Agent)
- ✅ Equipe especializada orquestrada (CRM)
- ✅ Auditoria de operações reais (LOSA)
- ✅ Checklists obrigatórios (Checklists de aviação)
- ✅ Foco total sem atividades não essenciais (Sterile Cockpit)
- ✅ Análise de causa raiz profunda (RCA)
- ✅ Postura de aprendizado, não punição (Just Culture)
- ✅ Classificação e priorização estruturada (HFACS parcial)

### O squad pode fortalecer:
- 🔄 Formalizar TEM: classificar explicitamente ameaças vs. erros vs. estados indesejados
- 🔄 Mapear classificação aos 4 níveis HFACS
- 🔄 Adicionar 5-Why e Fishbone formais ao Deep-Agent
- 🔄 Implementar ciclo PDCA entre auditorias
- 🔄 Criar "Dirty Dozen" para IA conversacional
- 🔄 Implementar briefing/debriefing formal entre agentes
- 🔄 Criar sistema de reporte voluntário para operadores
- 🔄 Versionamento e revisão periódica dos SOPs dos agentes

### O princípio mais importante da aviação para o squad:
> **"Toda falha deve gerar prevenção."** Cada auditoria não é apenas um relatório — é uma oportunidade de mudar o sistema para que aquela falha específica não se repita. O valor não está em encontrar erros, mas em transformar erros encontrados em melhorias permanentes.

---

## Fontes

Consolidação de todas as fontes dos documentos 01 a 14 desta série, combinadas com análise do squad auditor-real em `/home/AIOS-Total/aios-core/squads/auditor-real/`.
