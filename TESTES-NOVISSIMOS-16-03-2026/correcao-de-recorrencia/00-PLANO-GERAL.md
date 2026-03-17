# Plano de Correção — Falsos Conflitos em Eventos Recorrentes

**Data:** 2026-03-17
**Problema:** Eventos recorrentes expandidos são detectados como conflitos mesmo sem overlap real.

---

## Causa Raiz

O fluxo atual calcula um **range global** (data mais cedo → data mais tarde) de todos os eventos do batch recorrente e faz UMA query no Supabase com esse range. Qualquer evento existente que caia em qualquer ponto desse range é puxado — mesmo que não tenha overlap com nenhum evento específico.

**Exemplo:**
- Recorrência: toda segunda 10h–11h, 4 semanas (17/03 a 07/04)
- Range calculado: 17/03T10:00 → 07/04T11:00
- Evento existente "Dentista" quarta 19/03 14h → puxado como conflito (está dentro do range), mas NÃO conflita com nenhuma segunda

Adicionalmente, os eventos são criados ANTES da checagem, então os próprios eventos recém-criados aparecem na query como "conflitos" de si mesmos.

---

## Arquivos deste plano

| # | Arquivo | O que é |
|---|---------|---------|
| 1 | `00-PLANO-GERAL.md` | Este documento — visão geral |
| 2 | `01-CODE-NODE-VERIFICAR-CONFLITOS-REAIS.js` | Code node (JavaScript) que substitui o "Eh Conflito Real?" por verificação per-event |
| 3 | `02-CODE-NODE-FORMATAR-AVISO.js` | Code node para formatar a mensagem de aviso de conflito com detalhes reais |
| 4 | `03-SET-NODE-RANGE-BATCH.md` | Configuração corrigida do node "Set Range (Batch)" |
| 5 | `04-QUERY-SUPABASE-CORRIGIDA.md` | Query corrigida do "Buscar Conflitos (Batch)" |
| 6 | `05-PASSO-A-PASSO-IMPLEMENTACAO.md` | Tutorial completo de como aplicar no N8N |

---

## Ordem de execução

1. Ler o `05-PASSO-A-PASSO-IMPLEMENTACAO.md` primeiro para entender o fluxo
2. Aplicar as mudanças node a node conforme descrito
3. Testar com cenário de recorrência (ex: "crie reunião toda segunda 10h por 4 semanas")
4. Verificar que eventos não-sobrepostos NÃO geram aviso
