# Bateria de Testes #03 — Eventos Recorrentes + Edição/Exclusão
**Data:** 2026-03-15
**Ambiente:** N8N Dev (http://76.13.172.17:5678)
**Foco:** Confirmar problemas de edição/exclusão de eventos recorrentes

---

## MÓDULO 11: EVENTOS RECORRENTES — EDIÇÃO E EXCLUSÃO (10 cenários)

| # | Input | Latência | Resposta da IA | Resultado |
|---|-------|----------|----------------|-----------|
| 11.1 | "aula de inglês toda terça e quinta às 19h" | 5.0s | ✅ Evento recorrente registrado! | ✅ Criação OK |
| 11.2 | "muda a aula de inglês pra 20h" | **18.3s** | "Não encontrei eventos com esses critérios" | ❌ **NÃO CONSEGUIU EDITAR** |
| 11.3 | "cancela aula de inglês dessa terça" | 11.7s | 🗑️ Excluído! 17/03 19:00 | ⚠️ Excluiu mas pode ter apagado a série toda |
| 11.4 | "cancela todas as aulas de inglês" | 7.1s | "Não encontrei nenhum evento" | ❌ **NÃO ENCONTROU** (acabou de criar!) |
| 11.5 | "pilates toda segunda e quarta às 8h" | 4.9s | ✅ Evento recorrente registrado! | ✅ Criação OK |
| 11.6 | "muda pilates de quarta para sexta" | 9.3s | Atualizou para 20/03 08:00 | ⚠️ Editou UMA ocorrência, não a regra de recorrência |
| 11.7 | "exclui o pilates" | 16.0s | Listou 5 ocorrências e pediu confirmação | ⚠️ Bom UX mas não excluiu direto |
| 11.8 | "o que tenho de recorrente?" | 9.3s | Listou agenda 15/03 a 15/04 com Vitamina e Pilates | ✅ OK |
| 11.9 | "me lembra todo dia 5 de pagar aluguel" | **67.9s** | ❌ TIMEOUT | ❌ **QUEBROU** — recorrência mensal |
| 11.10 | "cancela lembrete do aluguel" | **40.3s** | "Não encontrei" | ❌ Nem criou (timeout anterior) |

---

## DIAGNÓSTICO: O que está quebrando

### 1. CRIAR recorrente: ✅ FUNCIONA (~5s)
- Diário, semanal com múltiplos dias: OK
- **Mensal (dia 5): TIMEOUT (68s)** — Quebra total

### 2. EDITAR recorrente: ❌ FALHA GRAVE
- **Não encontra o evento** para editar (11.2): 18s + falha
- Quando encontra, edita **apenas UMA ocorrência** ao invés da regra (11.6)
- Não oferece opção: "editar esta ocorrência ou todas?"

### 3. EXCLUIR recorrente: ❌ INCONSISTENTE
- Excluir uma ocorrência: funciona mas pode estar apagando a série
- Excluir todas: **"Não encontrei"** logo após criar (11.4)
- Exclusão com confirmação (11.7): bom UX mas fluxo longo

### Mapa de latência:

```
Criar recorrente semanal:   ~5s   ✅
Criar recorrente mensal:    ~68s  ❌ TIMEOUT
Editar recorrente:          ~18s  ❌ Falha
Excluir uma ocorrência:     ~12s  ⚠️
Excluir todas:              ~7s   ❌ "Não encontrei"
Consultar recorrentes:      ~9s   ✅
```

---

## RISCO DO SCHEDULE TRIGGER (Lembretes)

### O que sabemos:
- Criar lembretes simples: ✅ funciona
- Criar lembretes recorrentes diários: ✅ funciona
- Criar lembretes recorrentes mensais: ❌ TIMEOUT

### Riscos identificados SEM acesso ao workflow:

| Risco | Probabilidade | Impacto |
|-------|--------------|---------|
| Schedule trigger inativo no n8n dev | Alta | Lembretes nunca disparam |
| Recorrência mensal quebra ao expandir instâncias | Alta (confirmado no teste 11.9) | Lembretes mensais nunca são criados |
| Campo `next_fire_at` não atualizado após disparo | Média | Lembrete dispara uma vez e para |
| Campo `remembered` não marcado após envio | Média | Lembrete dispara infinitamente |
| Timezone errado no schedule trigger | Média | Lembrete chega na hora errada |

### Para confirmar esses riscos preciso:
1. **API key do n8n dev** — para ler o workflow do schedule trigger
2. **Ou**: acesso visual ao n8n dev para ver as execuções recentes do schedule

---

## CONCLUSÃO

**Seu sentimento está 100% correto:** edição e exclusão de recorrentes têm problemas graves. O sistema CRIA bem mas não consegue EDITAR nem EXCLUIR de forma confiável.
