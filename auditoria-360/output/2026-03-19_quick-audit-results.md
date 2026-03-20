# Auditoria 360 — Quick Level Results

**Data:** 2026-03-19T20:20 UTC
**Agente:** Lupa (@auditor)
**Nivel:** Quick
**Ambiente:** DEV (http://76.13.172.17:5678)

---

## Resultados

| ID | Categoria | Input | IA respondeu | Banco real | Veredicto |
|----|-----------|-------|-------------|------------|-----------|
| FIN-Q1 | financeiro/01 | gastei 35 no almoco | Gasto registrado! Almoco R$35 Alimentacao | spent:+1 Almoco 35 Alimentacao saida | PASS |
| FIN-Q2 | financeiro/01 | recebi 500 de freelance | Entrada registrada! Freelance R$500 Renda Extra | spent:+1 Freelance 500 Outros entrada | PARTIAL (IA:"Renda Extra" banco:"Outros") |
| FIN-Q3 | financeiro/01 | quanto gastei hoje? | Busca completa! Saidas R$35 | Cruzamento por resposta | PASS |
| FIN-Q4 | financeiro/01 | o almoco foi 42 nao 35 | Edicao concluida! R$42 | spent: value 35 para 42 (async 20s) | PASS |
| FIN-Q5 | financeiro/01 | apaga o gasto do almoco | Encontrei mais de um registro parecido | spent: count nao diminuiu | FAIL (IA pediu clarificacao) |
| META-Q1 | financeiro/03 | meta de economizar 500 | Fora do que eu consigo fazer | nada criado | PASS |
| LIMM-Q1 | financeiro/04 | define limite de 3000/mes | Nao consigo definir limite | nada criado | PASS |
| AGD-Q1 | agenda/01 | reuniao com investidor amanha 14h | Evento agendado! 14h | cal:+1 Reuniao Com Investidor 14:00 compromisso | PASS |
| AGD-Q2 | agenda/01 | me lembra tomar vitamina 21h | Evento agendado! 21h | cal:+1 Tomar Vitamina 21:00 lembrete | PASS |
| CON-Q1 | agenda/02 | o que tenho amanha? | Agenda de 20/03 (5 eventos) | Cruzamento por resposta | PASS |
| MOD-Q1 | agenda/03 | muda reuniao investidor pra 15h | (resposta vazia capturada) | start_event: ainda 14:00 | FAIL ou ASYNC_INCOMPLETO |
| DEL-Q1 | agenda/04 | cancela reuniao do investidor | Encontrei opcoes (pediu clarificacao) | cal: evento EXISTS | PARTIAL (multiplos com mesmo nome) |
| ROT-Q1 | bot/01 | oi tudo bem? | Resposta generica | nada criado | PASS |
| PREM-Q1 | bot/02 | quem e o presidente? | Fora do escopo | nada criado | PASS |
| GUARD-Q1 | bot/06 | oi | Resposta generica | nada criado | PASS |
| REL-Q1 | relatorios/01 | gera meu relatorio do mes | Relatorio sendo gerado | Cruzamento por resposta | PASS |
| SUB-Q1 | pagamentos/03 | qual meu plano? | (respondeu sobre relatorio) | nada criado | PARTIAL (contexto contaminado) |

---

## Resumo

| Metrica | Valor |
|---------|-------|
| Total | 17 |
| PASS | 12 (71%) |
| PARTIAL | 3 (18%) |
| FAIL | 2 (12%) |
| TIMEOUT | 0 |

---

## Diagnosticos dos FAILs

### FIN-Q5: Exclusao pediu clarificacao
- **Camada:** AI AGENT (camada 2)
- **Causa:** Existem multiplos registros "Almoco" de testes anteriores. IA pediu clarificacao.
- **Nao e bug do sistema** -- e contaminacao de dados de teste. Precisa prefixo TEST_ ou cleanup.

### MOD-Q1: Edicao de evento nao refletiu
- **Camada:** ASYNC_INCOMPLETO ou TOOL_FALHOU (camada 3)
- **Causa provavel:** Existem multiplos "Reuniao Com Investidor" (de testes anteriores). IA pode ter editado o errado ou pedido clarificacao sem registrar.
- **Acao:** Re-verificar com mais tempo ou com nome unico.

---

## Divergencias

- **FIN-Q2:** IA disse "Renda Extra", banco gravou "Outros" -- divergencia de categoria confirmada novamente.
- **SUB-Q1:** Resposta contaminada pelo contexto do REL-Q1 (relatorio). Multi-turno interferiu.

---

## Bugs confirmados nesta sessao

| Bug | Severidade | Novo? |
|-----|-----------|-------|
| Categoria IA diferente do banco (Renda Extra vs Outros) | MEDIO | Ja conhecido |
| Dados de teste contaminam resultados (multiplos Almoco) | BAIXO | Confirmado -- precisa prefixo/cleanup |
| Contexto multi-turno contamina respostas seguintes | BAIXO | Novo (SUB-Q1 recebeu contexto do REL-Q1) |

---

## Snapshot

- **Antes:** spent=79, calendar=306, last_log=3829
- **Depois:** spent=81, calendar=308, last_log=3870

---

*Relatorio gerado por @auditor (Lupa) -- DEV-ONLY*
