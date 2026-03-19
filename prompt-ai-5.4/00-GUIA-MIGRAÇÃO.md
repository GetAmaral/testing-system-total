# Guia de Migração: Prompts v3 para GPT-5.4-mini

## Arquitetura

```
User Message
  -> Escolher Branch (01-classificador.txt) → classifica intenção
  -> Switch → Set node (prompt específico) → Aggregate
  -> AI Agent (02-master-system.txt + prompt específico injetado)
  -> Response
```

## Onde colar cada arquivo no N8N

| # | Arquivo | Node N8N | Campo |
|---|---------|----------|-------|
| 01 | 01-classificador.txt | "Escolher Branch" | Prompt (chainLlm) |
| 02 | 02-master-system.txt | "AI Agent" | systemMessage |
| 03 | 03-criar-evento.txt | Set "prompt_criar1" | assignments.prompt.value |
| 04 | 04-registrar-gasto.txt | Set "registrar_gasto" | assignments.prompt.value |
| 05 | 05-buscar-agenda.txt | Set "prompt_busca1" | assignments.prompt.value |
| 06 | 06-excluir-evento.txt | Set "prompt_excluir" | assignments.prompt.value |
| 07 | 07-excluir-financeiro.txt | Set "excluir2" | assignments.prompt.value |
| 08 | 08-editar-evento.txt | Set "prompt_editar1" | assignments.prompt.value |
| 09 | 09-editar-financeiro.txt | Set "editar_gasto" | assignments.prompt.value |
| 10 | 10-lembrete.txt | Set "prompt_lembrete" | assignments.prompt.value |
| 11 | 11-recorrente.txt | Set "prompt_lembrete1" | assignments.prompt.value |
| 12 | 12-padrao.txt | Set "padrao" | assignments.prompt.value |
| 13 | 13-buscar-financeiro.txt | Set "buscar_gasto" | assignments.prompt.value |
| 14 | 14-relatorio-semanal.txt | Set "prompt_rel_semanal" | assignments.prompt.value |
| 15 | 15-relatorio-mensal.txt | Set "prompt_rel_mensal" | assignments.prompt.value |

## Config nos Nodes OpenAI

- **Model:** gpt-5.4-mini
- **Temperature:** 0 (classificador, criação, edição, exclusão, busca) | 0.3 (padrão/conversacional)
- NOTA: Temperature SÓ funciona com reasoning_effort: none no GPT-5.4

## O que foi corrigido (baseado em 147 interações reais)

### Exclusão em massa (era 10% OK)
- "todas/todos/tudo" agora executa sem confirmação
- Número após lista = seleção imediata
- Regra anti-loop: se user já confirmou → EXECUTE

### Classificação errada (5 falhas graves)
- "Recebi 169.587 total" → agora PASSO 6 captura antes de qualquer busca
- "massagear os pés do amaral 19h" → agora PASSO 10: qualquer texto + horário = evento
- "16 de Abril Senai Presencial" → agora PASSO 10: data sem hora também = evento
- "Fazer grupo da Comissão" + "para hoje" → PASSO 10 captura

### Perda de contexto (4 falhas)
- Master system agora tem regras explícitas de resolução de referências
- "me lembre disso" → olha ÚLTIMA mensagem do user
- "na verdade foram R$300" → EDITAR, não criar novo

### Edição indesejada (3 falhas)
- Regra "EDITE APENAS O QUE O USER PEDIU" em editar-evento e editar-financeiro
- "muda pizza pra pizzaria" → SÓ nome, nunca valor

### Eventos recorrentes (era 0% OK)
- Prompt reescrito com exemplos explícitos de RRULE
- "yoga toda terça e quinta 7h" → FREQ=WEEKLY;BYDAY=TU,TH

## Ordem de deploy recomendada

1. Classificador (01) + Master (02) → testar com mensagens que falharam
2. Exclusão (06, 07) → testar "exclui tudo", "todas"
3. Criação (03, 04, 10) → testar eventos informais + receitas
4. Edição (08, 09) → testar "muda nome sem mudar valor"
5. Busca (05, 13) + Relatórios (14, 15) + Padrão (12) + Recorrente (11)