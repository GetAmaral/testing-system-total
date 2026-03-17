# Passo a Passo — Implementação Completa

**Tempo estimado:** 15–20 minutos no N8N

---

## Visão geral da mudança

### ANTES (fluxo atual com bug):
```
HTTP Create Tool6 → Aggregate5 → lastGet7 → If9 → Redis8
  → Set Range (Batch) → Buscar Conflitos (Batch) → Eh Conflito Real? (IF)
    → TRUE: Aggregate1 → Aviso Conflito (WhatsApp)
    → FALSE: Sem Conflito (NoOp)
```

**Problema:** O range global puxa eventos que não conflitam de verdade.

### DEPOIS (fluxo corrigido):
```
HTTP Create Tool6 → Aggregate5 → lastGet7 → If9 → Redis8
  → Set Range (Batch) → Buscar Conflitos (Batch)
    → [CODE] Verificar Conflitos Reais → [IF] Tem Conflito?
      → TRUE: [CODE] Formatar Aviso → Aviso Conflito (WhatsApp)
      → FALSE: Sem Conflito (NoOp)
```

**Correção:** Code node verifica overlap par-a-par entre cada evento novo e existente.

---

## Passo 1 — Editar "Set Range (Batch)"

1. Abrir o node **Set Range (Batch)**
2. **Remover** o campo `nomes_batch`
3. **Adicionar** novo campo:
   - **Name:** `eventos_novos_json`
   - **Type:** String
   - **Value:** (colar exatamente)
   ```
   {{ JSON.stringify($('Switch2').first().json.parsed_output.tool) }}
   ```
4. Manter `user_id`, `range_start` e `range_end` sem mudança
5. Salvar

**Por que:** O Code node precisa dos dados completos dos eventos para comparar horários.

---

## Passo 2 — Criar Code node "Verificar Conflitos Reais"

1. Adicionar um novo node **Code** (JavaScript)
2. Nomear: `Verificar Conflitos Reais`
3. Colar o conteúdo inteiro do arquivo `01-CODE-NODE-VERIFICAR-CONFLITOS-REAIS.js`
4. **Conectar:**
   - ENTRADA ← saída do **Buscar Conflitos (Batch)**
   - (saída será conectada no passo 4)

**Por que:** Este node faz a verificação de overlap real entre pares de eventos — a correção principal do bug.

---

## Passo 3 — Criar IF node "Tem Conflito?"

1. Adicionar um novo node **IF**
2. Nomear: `Tem Conflito?`
3. Configurar condição:
   - **Left Value:** `{{ $json.conflito }}`
   - **Operator:** Boolean → is true
4. **Conectar:**
   - ENTRADA ← saída do **Verificar Conflitos Reais**
   - TRUE → vai para o **Passo 4** (formatar aviso)
   - FALSE → vai para **Sem Conflito (Batch)** (NoOp existente)

**Por que:** Substitui o "Eh Conflito Real?" que usava comparação por nome. Agora a decisão é baseada na flag `conflito` retornada pelo Code node.

---

## Passo 4 — Criar Code node "Formatar Aviso"

1. Adicionar um novo node **Code** (JavaScript)
2. Nomear: `Formatar Aviso Conflito`
3. Colar o conteúdo inteiro do arquivo `02-CODE-NODE-FORMATAR-AVISO.js`
4. **Conectar:**
   - ENTRADA ← saída TRUE do **Tem Conflito?**
   - SAÍDA → **Aviso Conflito (Batch)** (WhatsApp node existente)

**Por que:** Gera uma mensagem detalhada mostrando quais eventos conflitam (com datas), em vez de listar nomes genéricos.

---

## Passo 5 — Atualizar "Aviso Conflito (Batch)" (WhatsApp)

1. Abrir o node **Aviso Conflito (Batch)**
2. Alterar o campo **Text Body** de:
   ```
   ⚠️ *Atenção:* seus novos eventos coincidem com evento(s) já existentes:

   - {{ ($json.data || []).map(e => (e.event_name?.trim() || 'Sem Título')).join('\n- ') }}

   Verifique sua agenda.
   ```
   **Para** (colar exatamente):
   ```
   {{ $json.mensagem_conflito }}
   ```
3. Salvar

**Por que:** A mensagem agora vem pronta do Code node "Formatar Aviso Conflito", com detalhes de cada par conflitante.

---

## Passo 6 — Desconectar/remover node antigo

1. **Desconectar** o node **"Eh Conflito Real?"** (IF node antigo)
   - Remover a conexão entre "Buscar Conflitos (Batch)" e "Eh Conflito Real?"
   - Remover as conexões de saída do "Eh Conflito Real?"
2. Pode **deletar** o node ou apenas deixar desconectado (recomendo deletar para limpar)
3. Verificar que **"Aggregate1"** agora não está mais conectado diretamente — ele receberá dados do path TRUE do novo IF

**Por que:** O "Eh Conflito Real?" é o node com o bug. Ele é completamente substituído pelo Code + IF novos.

---

## Passo 7 — Reconectar o Aggregate1

1. O node **Aggregate1** precisa receber os conflitos reais
2. **Conectar:**
   - ENTRADA do Aggregate1 ← saída TRUE do **Tem Conflito?**
   - SAÍDA do Aggregate1 → **Formatar Aviso Conflito** (Code node do passo 4)
3. Saída do **Formatar Aviso Conflito** → **Aviso Conflito (Batch)** (WhatsApp)

**Fluxo final TRUE:**
```
Tem Conflito? [TRUE] → Aggregate1 → Formatar Aviso Conflito → Aviso Conflito (Batch)
```

---

## Passo 8 — Reconectar path FALSE (sem conflito)

1. **Conectar:**
   - FALSE do **Tem Conflito?** → **Sem Conflito (Batch)** (NoOp existente)
2. Manter o restante do fluxo pós-NoOp igual (Aggregate9 → Merge → etc.)

---

## Diagrama final das conexões

```
Buscar Conflitos (Batch)
         │
         ▼
Verificar Conflitos Reais (CODE - arquivo 01)
         │
         ▼
    Tem Conflito? (IF)
      │          │
    TRUE       FALSE
      │          │
      ▼          ▼
 Aggregate1   Sem Conflito (Batch)
      │          │
      ▼          ▼
 Formatar     Aggregate9
 Aviso           │
 (CODE-02)       ▼
      │        Merge
      ▼          │
 Aviso           ▼
 Conflito     Aggregate10
 (WhatsApp)      │
                 ▼
            Send message6
```

---

## Checklist de validação pós-implementação

| # | Teste | Resultado esperado |
|---|-------|--------------------|
| 1 | Criar evento recorrente "Teste" toda segunda 10h–11h, 4 semanas | Nenhum aviso de conflito (agenda vazia) |
| 2 | Criar evento "Dentista" quarta 14h–15h | Nenhum conflito com as segundas |
| 3 | Criar evento "Reunião" segunda 10h30–11h30 (overlap real) | Aviso de conflito com "Teste" da mesma segunda |
| 4 | Criar evento "Almoço" segunda 12h–13h (sem overlap) | Nenhum conflito (horários não se cruzam) |
| 5 | Criar 2 eventos em batch, 1 conflita e 1 não | Aviso mostra apenas o que conflita |

---

## Rollback (caso algo dê errado)

1. Reconectar o "Eh Conflito Real?" na saída do "Buscar Conflitos (Batch)"
2. Reconectar as saídas TRUE/FALSE do "Eh Conflito Real?" como estavam
3. Restaurar o Text Body do "Aviso Conflito (Batch)" para o valor original
4. Deletar os 3 nodes novos (Verificar Conflitos Reais, Tem Conflito?, Formatar Aviso)
