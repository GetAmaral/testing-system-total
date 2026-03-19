# Pesquisa Técnica: GPT-5.4-mini (gpt-5.4-mini)

**Data da pesquisa:** 19/03/2026
**Modelo:** gpt-5.4-mini (snapshot: gpt-5.4-mini-2026-03-17)
**Data de lançamento:** 17/03/2026
**Knowledge cutoff:** 31/08/2025

---

## 1. Diferenças entre GPT-5.4-mini e GPT-4.1-mini

### Especificações Técnicas

| Característica | GPT-4.1-mini | GPT-5.4-mini |
|---|---|---|
| Context window | 128K tokens | **400K tokens** |
| Max output | 32K tokens | **128K tokens** |
| Reasoning nativo | Não | **Sim (reasoning_effort)** |
| Computer use | Não | **Sim** |
| Tool search | Não | **Sim** |
| Custom tools (type: custom) | Não | **Sim** |
| CFG (Context-Free Grammar) | Não | **Sim** |
| Phase parameter | Não | **Sim** |
| Preço input | $0.40/1M | $0.75/1M |
| Preço output | $1.60/1M | $4.50/1M |
| Cached input | N/A | $0.075/1M |
| Velocidade (tokens/s) | ~90-100 t/s | **~180-190 t/s** |

### Mudanças de Comportamento

1. **Interpretação literal vs inferencial**: GPT-5.4-mini é **significativamente mais literal** e faz menos suposições. Onde GPT-4.1-mini inferia intenção a partir de contexto vago, GPT-5.4-mini segue instruções ao pé da letra. Isso exige prompts mais explícitos.

2. **Reasoning nativo**: GPT-5.4-mini é um **reasoning model** por padrão, mesmo sendo "mini". O default de reasoning_effort é `none`, o que significa velocidade similar ao 4.1-mini, mas com opção de ativar raciocínio quando necessário.

3. **Tool calling**: GPT-5.4-mini suporta tool search (carregamento dinâmico de tools), custom tools (output em texto livre, não JSON), e allowed_tools (restrição de quais tools podem ser chamadas). Isso é uma evolução significativa.

4. **Over-confirmation**: GPT-5.4-mini tende a gerar perguntas de follow-up ao invés de executar. Precisa de instrução explícita para "executar sem perguntar".

5. **Preamble antes de tool calls**: O modelo gera texto explicativo antes de chamar tools. Isso pode ser controlado com o parâmetro `phase` na Responses API, ou com instrução explícita anti-preamble.

---

## 2. Estrutura Ótima de Prompt para GPT-5.4-mini

### Ordem Recomendada (pela OpenAI)

```
1. OUTPUT CONTRACT (formato de saída) — PRIMEIRO
2. REGRAS CRÍTICAS (em ordem de prioridade)
3. DECISION TREE (lógica explícita)
4. TOOL PERSISTENCE RULES (quando chamar/parar tools)
5. DEPENDENCY CHECKS (pré-requisitos entre ações)
6. COMPLETENESS CONTRACT (o que significa "pronto")
7. VERIFICATION LOOP (auto-checagem antes de responder)
8. EXEMPLO (1 exemplo completo do fluxo, no final)
```

### Formatar Regras: Decision Trees > Prosa

**ERRADO (prosa):**
```
Você deve verificar se o evento tem data e hora. Se não tiver data, pergunte.
Se não tiver hora, use 09:00 como padrão. Nunca crie sem data.
```

**CERTO (decision tree):**
```
REGRAS DE VALIDAÇÃO:
1. SE mensagem contém data → extrair data
2. SE mensagem NÃO contém data → RESPONDER pedindo data. NÃO chamar tool.
3. SE mensagem contém hora → extrair hora
4. SE mensagem NÃO contém hora → usar "09:00" como padrão
5. SOMENTE chamar tool quando data estiver definida.
```

### Blocos Estruturais Recomendados

A OpenAI recomenda usar blocos XML-like para separar seções:

```
<output_contract>
Formato: responder APENAS com o JSON da tool call. Sem texto antes ou depois.
</output_contract>

<tool_persistence_rules>
- Máximo 1 tool call por turno
- NÃO pare se o resultado da tool indicar que mais ação é necessária
- NÃO chame a mesma tool duas vezes com os mesmos parâmetros
</tool_persistence_rules>

<completeness_contract>
A tarefa está completa quando: [definição explícita]
</completeness_contract>

<verification_loop>
Antes de responder, verificar:
1. O formato de saída está correto?
2. Todas as regras foram seguidas?
3. A resposta é completa?
</verification_loop>
```

### Exemplos: Mostrar o Fluxo Completo

Para GPT-5.4-mini, um exemplo deve mostrar TODO o fluxo de decisão, não apenas o output final:

```
EXEMPLO:
Usuário: "agenda reunião amanhã às 15h"
Análise: data=amanhã, hora=15:00, título="reunião"
Decisão: data presente + hora presente → chamar tool
Tool call: criar_evento(titulo="reunião", data="2026-03-20", hora="15:00")
```

---

## 3. Issues e Quirks Conhecidos do GPT-5.4-mini

### 3.1 Over-Confirmation / Follow-up desnecessário
**Problema:** O modelo tenta manter a conversa gerando perguntas de follow-up mesmo quando não são necessárias.
**Solução:** Adicionar instrução explícita:
```
APÓS executar a ação, responda confirmando o que foi feito.
NÃO faça perguntas de follow-up.
NÃO sugira próximos passos.
```

### 3.2 Preamble antes de Tool Calls
**Problema:** O modelo gera texto explicativo ("Vou criar o evento para você...") antes de chamar a tool.
**Solução:**
- Na Responses API: usar `phase: "commentary"` para preambles e `phase: "final_answer"` para resposta final
- No Chat Completions: adicionar instrução explícita:
```
NÃO gere texto antes de chamar uma tool.
Chame a tool DIRETAMENTE, sem explicar o que vai fazer.
```

### 3.3 Interpretação Excessivamente Literal
**Problema:** GPT-5.4-mini segue instruções ao pé da letra, ignorando contexto implícito.
**Solução:** Tornar TUDO explícito. Não confiar em inferência. Cada edge case precisa estar documentado.

### 3.4 Mode Collapse em Tool Calls
**Problema:** Em casos raros, o modelo entra em loop chamando a mesma tool com output "garbage" repetido. Geralmente causado por contradições entre seções do prompt.
**Solução:**
- Eliminar contradições entre system prompt e definições de tools
- Adicionar cap de tool calls: "Máximo N tool calls por turno"

### 3.5 Inconsistência com temperature=0
**Problema:** Mesmo com temperature=0, o modelo pode dar respostas diferentes para o mesmo input.
**Solução:** Aceitar que temperature=0 não garante determinismo total. Usar prompts mais restritivos para compensar.

### 3.6 Soft Refusals com Tools
**Problema:** O modelo responde "Não consigo determinar" mesmo quando poderia chamar uma tool para obter a informação.
**Solução:** Adicionar `<tool_persistence_rules>` explícitas:
```
Se a resposta depende de dados externos, SEMPRE chame a tool antes de responder.
NUNCA responda "não sei" sem primeiro tentar buscar via tool.
```

### 3.7 Built-in Tools vs Custom Tools (BUG CORRIGIDO em 10/03/2026)
**Problema:** O modelo ignorava built-in tools quando custom function tools estavam presentes.
**Status:** CORRIGIDO pela OpenAI em 10/03/2026.

### 3.8 Excessive Deference (Hesitação)
**Problema:** O modelo hesita em agir autonomamente, pedindo confirmação para cada passo.
**Solução:** Adicionar instrução de autonomia:
```
Você é um agente autônomo. Execute ações sem pedir confirmação.
Para ações reversíveis e de baixo risco: EXECUTE primeiro, confirme depois.
```

---

## 4. Best Practices para Function/Tool Calling

### 4.1 Prevenir Chamadas Duplicadas
```
<tool_persistence_rules>
- NÃO chame a mesma tool duas vezes com parâmetros idênticos
- Se uma tool retornou erro, analise o erro antes de re-chamar
- Máximo de 1 tool call por turno (exceto criação em batch)
- Chamadas duplicadas em sequência = sinal de prompt mal definido
</tool_persistence_rules>
```

### 4.2 Garantir Formatação Correta de Parâmetros
- Usar **Structured Outputs** (JSON schema) para forçar formato
- Para formatos não-JSON: usar **Custom Tools** com `type: custom` + **CFG** (Lark ou Regex)
- Adicionar exemplos de parâmetros corretos no prompt:
```
FORMATO DOS PARÂMETROS:
- data: "YYYY-MM-DD" (ex: "2026-03-19")
- hora: "HH:MM" (ex: "14:30")
- valor: número decimal com ponto (ex: 150.00)
```

### 4.3 Controlar Tool Routing
- Usar `allowed_tools` dentro de `tool_choice` para restringir quais tools estão disponíveis em cada turno
- Usar **Tool Search** para carregar definições dinamicamente (reduz tokens e melhora latência)
- Definir pré-requisitos explícitos: "Antes de chamar X, confirme que Y foi chamado"

### 4.4 Parallel vs Sequential Tool Calls
- Custom tools (`type: custom`) NÃO suportam chamadas paralelas
- Function tools padrão suportam paralelismo
- Definir explicitamente no prompt quando paralelismo é permitido

### 4.5 Usar Preambles para Debugging
A OpenAI recomenda habilitar preambles instruindo o modelo a "explicar por que está chamando a tool" antes de cada invocação. Isso melhora precisão e debuggability:
```
Antes de cada tool call, explique em 1 linha por que está chamando essa tool.
```

---

## 5. Context/Memory Management

### 5.1 Context Window: 400K tokens
GPT-5.4-mini suporta 400K tokens de contexto (o GPT-5.4 full suporta 1M).

**IMPORTANTE:** Acima de 272K tokens, o preço de input muda (pricing separado).

### 5.2 Cached Input (Prompt Caching)
- Input cacheado custa **$0.075/1M** (90% de desconto)
- Para maximizar cache: manter a parte estável do prompt (system message, tools) no início
- Variações (user message) devem ir no final

### 5.3 Compaction API (para sessões longas)
Para conversas multi-turno longas, usar a **Compaction API** para comprimir histórico:
- Compactar após marcos importantes (ex: após completar uma tarefa)
- Tratar items compactados como estado opaco
- Manter prompts funcionalmente idênticos após compactação

### 5.4 previous_response_id (Responses API)
Passar `previous_response_id` para reutilizar reasoning items anteriores:
- Evita re-reasoning
- Melhora performance de cache
- Especialmente útil em tool calling com múltiplos round trips

### 5.5 Preservar Phase em Multi-Turn
Ao reenviar mensagens anteriores do assistente, preservar o campo `phase` original. Se o phase for descartado, o modelo pode confundir preambles com respostas finais.

### 5.6 Performance com Contexto Grande
Observação da comunidade: GPT-5.4-mini tem performance degradada com contextos muito grandes. Funciona melhor com contextos de tamanho "mini" (< 100K). Para contextos maiores, considerar o GPT-5.4 full.

---

## 6. Reasoning Effort Parameter

### Valores Disponíveis para GPT-5.4-mini

| Valor | Suportado | Uso Recomendado |
|---|---|---|
| `none` | Sim (DEFAULT) | Extração, roteamento, classificação, transformações simples |
| `low` | Sim | Tarefas onde um pouco de raciocínio melhora confiabilidade |
| `medium` | Sim | Planejamento, coding, síntese, raciocínio moderado |
| `high` | Sim (MÁXIMO para mini) | Tarefas complexas que exigem raciocínio profundo |
| `xhigh` | **NÃO suportado no mini** | Apenas GPT-5.4 full |

### Recomendações por Caso de Uso (para N8N)

| Node/Função | reasoning_effort | Justificativa |
|---|---|---|
| Classificador de intenção | `none` ou `low` | Roteamento simples, latência mínima |
| Criação de evento/gasto | `low` | Extração de dados + validação simples |
| Busca de agenda/financeiro | `low` | Construção de query simples |
| Edição/Exclusão | `low` | Identificação de campos + validação |
| Relatórios (semanal/mensal) | `medium` | Síntese de dados requer mais raciocínio |
| Padrão (conversacional) | `medium` | Respostas mais elaboradas |

### Interação com Outros Parâmetros
- `reasoning_effort: none` → permite usar `temperature`, `top_p`, `logprobs`
- `reasoning_effort: low/medium/high` → **NÃO permite** temperature, top_p, logprobs
- Para controlar extensão da resposta com reasoning ativo: usar `text.verbosity` (low/medium/high)

### Estratégia de Otimização
A OpenAI recomenda: **melhorar o prompt PRIMEIRO, aumentar reasoning_effort DEPOIS.** O reasoning effort é um "ajuste fino de última milha", não o mecanismo principal de qualidade. Investir em:
1. Completeness contracts
2. Verification loops
3. Tool persistence rules
4. Exemplos claros

...antes de subir o reasoning_effort.

---

## 7. Temperature Settings

### Regra Fundamental
**Temperature SÓ funciona com `reasoning_effort: none`.**

Se reasoning_effort estiver em qualquer outro valor (low, medium, high), temperature causa ERRO na API.

### Valores Recomendados (com reasoning_effort: none)

| Tipo de Tarefa | Temperature | Justificativa |
|---|---|---|
| Classificação / Roteamento | 0 | Determinismo máximo |
| Extração de dados (JSON) | 0 | Formato consistente |
| Criação de evento/gasto | 0 | Parâmetros precisos |
| Busca (query building) | 0 | Queries consistentes |
| Edição/Exclusão | 0 | Ações precisas |
| Conversacional (padrão) | 0.3 | Leve variação para naturalidade |
| Relatórios | 0.3 | Leve variação na redação |

### Alternativa: Verbosity Parameter
Quando usando reasoning_effort > none, substituir temperature por `text.verbosity`:
- `"low"`: respostas curtas, mínimo de prosa
- `"medium"`: balanceado (default)
- `"high"`: respostas longas com explicações inline

---

## 8. Structured Output

### JSON Schema (Structured Outputs)
GPT-5.4-mini suporta Structured Outputs nativamente. Usar para forçar formato de resposta:
```json
{
  "type": "json_schema",
  "json_schema": {
    "name": "evento",
    "schema": {
      "type": "object",
      "properties": {
        "titulo": {"type": "string"},
        "data": {"type": "string", "pattern": "^\\d{4}-\\d{2}-\\d{2}$"},
        "hora": {"type": "string", "pattern": "^\\d{2}:\\d{2}$"}
      },
      "required": ["titulo", "data"]
    }
  }
}
```

### Context-Free Grammar (CFG)
Para formatos não-JSON (SQL, shell, DSLs), usar CFG com sintaxe Lark ou Regex para constrains de output.

### Anti-Prose para Parse
Quando o output precisa ser parseável:
```
Output APENAS o formato solicitado.
NÃO adicione prosa, explicações ou markdown fences.
NÃO adicione texto antes ou depois do formato.
```

---

## 9. Resumo de Configuração Recomendada para N8N

### Configuração Base de Todos os Nodes

```
Model: gpt-5.4-mini
reasoning_effort: none (para classificador, criação, busca, edição, exclusão)
                  medium (para padrão conversacional e relatórios)
temperature: 0 (quando reasoning_effort = none)
             N/A (quando reasoning_effort > none, usar verbosity)
```

### Checklist de Prompt para GPT-5.4-mini

- [ ] OUTPUT CONTRACT no início do prompt
- [ ] Regras em decision tree, não prosa
- [ ] Instrução anti-preamble ("NÃO gere texto antes de tool calls")
- [ ] Instrução anti-follow-up ("NÃO faça perguntas de follow-up")
- [ ] Cap de tool calls definido
- [ ] Formato de parâmetros com exemplos
- [ ] 1 exemplo completo do fluxo (input → análise → decisão → output)
- [ ] Completeness contract ("tarefa completa quando...")
- [ ] Sem contradições entre seções

---

## Fontes

- [GPT-5.4 mini Model | OpenAI API](https://developers.openai.com/api/docs/models/gpt-5.4-mini)
- [Introducing GPT-5.4 mini and nano | OpenAI](https://openai.com/index/introducing-gpt-5-4-mini-and-nano/)
- [Using GPT-5.4 | OpenAI API](https://developers.openai.com/api/docs/guides/latest-model)
- [Prompt Guidance for GPT-5.4 | OpenAI API](https://developers.openai.com/api/docs/guides/prompt-guidance)
- [GPT-5 Troubleshooting Guide | OpenAI Cookbook](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_troubleshooting_guide)
- [GPT-5 New Params and Tools | OpenAI Cookbook](https://developers.openai.com/cookbook/examples/gpt-5/gpt-5_new_params_and_tools)
- [Reasoning Models | OpenAI API](https://developers.openai.com/api/docs/guides/reasoning)
- [GPT-5.4 Release, weird tool behaviour | OpenAI Community](https://community.openai.com/t/gpt-5-4-release-weird-tool-behaviour/1375860)
- [Temperature in GPT-5 models | OpenAI Community](https://community.openai.com/t/temperature-in-gpt-5-models/1337133)
- [GPT-5.4 Mini and Nano | Hacker News](https://news.ycombinator.com/item?id=47415441)
- [GPT-5.4 Mini on OpenRouter](https://openrouter.ai/openai/gpt-5.4-mini)
- [9to5Google: GPT 5.4 mini](https://9to5google.com/2026/03/17/openai-gpt-5-4-mini-nano-models/)
- [9to5Mac: GPT-5.4 mini and nano](https://9to5mac.com/2026/03/17/openai-releases-gpt-5-4-mini-and-nano-its-most-capable-small-models-yet/)
