# Guia de Migração: Prompts v3 para GPT-5.4-mini

## Arquitetura dos Prompts

```
User Message
  -> Escolher Branch (01-classificador.txt) -> classifica intenção
  -> Switch -> Set node (prompt específico) -> Aggregate
  -> AI Agent (02-master-system.txt + prompt específico injetado)
  -> Response
```

## Arquivos e onde colar no N8N

| # | Arquivo | Node N8N | Campo |
|---|---------|----------|-------|
| 01 | 01-classificador.txt | "Escolher Branch" | Prompt (text do chainLlm) |
| 02 | 02-master-system.txt | "AI Agent" | systemMessage |
| 03 | 03-criar-evento.txt | Set node "prompt_criar1" | assignments.prompt.value |
| 04 | 04-registrar-gasto.txt | Set node "registrar_gasto" | assignments.prompt.value |
| 05 | 05-buscar-agenda.txt | Set node "prompt_busca1" | assignments.prompt.value |
| 06 | 06-excluir-evento.txt | Set node "prompt_excluir" | assignments.prompt.value |
| 07 | 07-excluir-financeiro.txt | Set node "excluir2" | assignments.prompt.value |
| 08 | 08-editar-evento.txt | Set node "prompt_editar1" | assignments.prompt.value |
| 09 | 09-editar-financeiro.txt | Set node "editar_gasto" | assignments.prompt.value |
| 10 | 10-lembrete.txt | Set node "prompt_lembrete" | assignments.prompt.value |
| 11 | 11-recorrente.txt | Set node "prompt_lembrete1" | assignments.prompt.value |
| 12 | 12-padrao.txt | Set node "padrao" | assignments.prompt.value |
| 13 | 13-buscar-financeiro.txt | Set node "buscar_gasto" | assignments.prompt.value |
| 14 | 14-relatorio-semanal.txt | Set node "prompt_rel_semanal" | assignments.prompt.value |
| 15 | 15-relatorio-mensal.txt | Set node "prompt_rel_mensal" | assignments.prompt.value |

## Configurações no Node OpenAI do N8N

Para TODOS os nodes OpenAI Chat Model:
- **Model:** gpt-5.4-mini
- **Temperature:** 0 (para classificador e criação) ou 0.3 (para padrão/conversacional)

Se o N8N suportar `reasoning_effort`:
- Classificador: `none` ou `low`
- Criação de evento/gasto: `low`
- Busca: `low`
- Edição/Exclusão: `low`
- Padrão (conversacional): `medium`

## Princípios da Reestruturação

1. **OUTPUT FORMAT primeiro** — modelo sabe o alvo antes de processar regras
2. **Regras em ordem de prioridade** — as mais importantes primeiro
3. **Decision trees** — lógica explícita ao invés de prosa
4. **Zero contradições** — cada regra tem hierarquia clara
5. **Exemplos minimais** — 1-2 por caso, sem redundância
6. **Anti-preamble** — instrução explícita para não gerar texto antes de agir
7. **Cap de tool calls** — máximo 1 tool call por turno (exceto quando múltiplos itens)
8. **Decisividade** — "EXECUTE, não pergunte" em linguagem forte

## Economia de Tokens

| Prompt | Antes (chars) | Depois (chars) | Redução |
|--------|--------------|----------------|---------|
| Classificador | ~5,580 | ~3,200 | -43% |
| Master System | ~4,935 | ~2,800 | -43% |
| Criar Evento | ~3,950 | ~3,100 | -22% |
| Registrar Gasto | ~4,830 | ~3,200 | -34% |
| Buscar Agenda | ~7,420 | ~3,800 | -49% |
| Excluir Evento | ~5,960 | ~2,900 | -51% |
| Excluir Financ. | ~5,670 | ~2,700 | -52% |
| Editar Evento | ~8,650 | ~3,500 | -60% |
| Editar Financ. | ~7,150 | ~3,200 | -55% |
| TOTAL | ~75,403 | ~42,000 | -44% |
