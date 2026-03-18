# Auditoria 360° — Checklist de Verificação End-to-End

**OBRIGATÓRIO**: Todo teste de CRUD DEVE seguir este checklist completo.
Nenhum teste é "✅ CONFIRMADO" sem todas as verificações aplicáveis.

---

## Para cada teste: 3 fases obrigatórias

### FASE 1: SNAPSHOT ANTES

- [ ] **Contar registros na tabela alvo** (`spent` ou `calendar`) — salvar contagem
- [ ] **Buscar registro específico por nome** (se edição/exclusão) — salvar estado completo
- [ ] **Registrar hora UTC exata** do snapshot

### FASE 2: EXECUTAR AÇÃO

- [ ] **Enviar mensagem** via webhook dev
- [ ] **Registrar hora UTC** do envio
- [ ] **Aguardar processamento** (mínimo 18s para ações complexas)
- [ ] **Capturar resposta da IA** (log_users_messages, último registro)
- [ ] **Verificar que log_id é NOVO** (não é resposta anterior sendo repetida)

### FASE 3: SNAPSHOT DEPOIS + CRUZAMENTO

- [ ] **Contar registros na tabela alvo** — comparar com ANTES
- [ ] **Buscar registro por nome** — comparar TODOS os campos com ANTES
- [ ] **Cruzar CADA campo** da resposta da IA com o banco real (tabela abaixo)

---

## Cruzamento IA vs Banco — Campos obrigatórios

### Para GASTOS (tabela `spent`):

| Campo IA | Campo DB | Verificar |
|----------|----------|-----------|
| Nome do gasto | `name_spent` | Iguais? |
| Valor | `value_spent` | Iguais? |
| Categoria que IA disse | `category_spent` | Iguais? ⚠️ Bug conhecido: IA diz "Renda Extra", banco grava "Outros" |
| Tipo (gasto/receita) | `transaction_type` (saida/entrada) | Correto? |
| *(não informado pela IA)* | `type_spent` (variavel/fixo/eventuais) | Classificação coerente? |
| *(não informado pela IA)* | `date_spent` | Data correta? (mesmo dia do envio?) |
| *(não informado pela IA)* | `created_at` | Timestamp ±5s da mensagem? |
| *(não informado pela IA)* | `fk_user` | É o user correto? |

### Para EVENTOS (tabela `calendar`):

| Campo IA | Campo DB | Verificar |
|----------|----------|-----------|
| Nome do evento | `event_name` | Iguais? |
| Data/hora início | `start_event` | Iguais? |
| *(não informado pela IA)* | `end_event` | Duração padrão 30min coerente? |
| *(não informado pela IA)* | `compromisso_tipo` | Correto? (compromisso/lembrete) |
| *(não informado pela IA)* | `is_recurring` | Se recorrente, é true? |
| *(não informado pela IA)* | `rrule` | Se recorrente, rrule correto? (BYDAY, FREQ) |
| *(não informado pela IA)* | `connect_google` | Sincronizado com Google? |
| *(não informado pela IA)* | `session_event_id_google` | Google event ID existe? |
| *(não informado pela IA)* | `active` | true? |
| *(não informado pela IA)* | `due_at` | Lembrete configurado? |
| *(não informado pela IA)* | `timezone` | America/Sao_Paulo? |

---

## Verificações específicas por tipo de operação

### CREATE (gasto ou evento)
- [ ] Contagem da tabela aumentou em exatamente 1
- [ ] Registro encontrado com nome e valor corretos
- [ ] Todos os campos do cruzamento acima verificados
- [ ] Não houve duplicata (buscar por nome — deve retornar exatamente 1 novo)

### UPDATE (editar valor, nome, categoria, data)
- [ ] **ANTES**: salvar estado completo do registro (todos os campos)
- [ ] **DEPOIS**: buscar registro e comparar campo editado
- [ ] **CAMPO EDITADO mudou** para o novo valor
- [ ] **CAMPOS NÃO EDITADOS permaneceram iguais** (regressão)
- [ ] Contagem da tabela NÃO mudou (não criou registro novo)
- [ ] ⚠️ BUG CONHECIDO: IA diz "Edição concluída" mas banco não muda. SEMPRE verificar.

### DELETE (gasto ou evento)
- [ ] **ANTES**: registro existe (salvar id)
- [ ] **DEPOIS**: registro NÃO existe mais (buscar pelo id)
- [ ] Contagem da tabela diminuiu em exatamente 1
- [ ] Nenhum outro registro foi afetado (contagem diminuiu em EXATAMENTE 1, não mais)

### CREATE RECORRENTE (evento)
- [ ] Registro criado com `is_recurring: true`
- [ ] `rrule` contém FREQ correto (WEEKLY, MONTHLY, etc.)
- [ ] `rrule` contém BYDAY correto (TU, TH para terça/quinta, etc.)
- [ ] NÃO criou duplicata (contar eventos com mesmo nome)
- [ ] Apenas 1 registro no banco (não expandiu em múltiplos)

### CONSULTA/BUSCA (quanto gastei, agenda de hoje)
- [ ] Fazer SELECT independente na tabela com mesmos filtros
- [ ] Comparar: registros retornados pela IA = registros no banco
- [ ] Comparar: valores/saldo calculados pela IA = soma real no banco
- [ ] ⚠️ BUG CONHECIDO: IA pode ignorar entradas ao calcular saldo

---

## O que NÃO conseguimos verificar (e por quê)

| Item | Razão | Impacto |
|------|-------|---------|
| Entrega no WhatsApp | Sem acesso à Meta API de leitura | Assumimos que se foi logado, foi entregue |
| Sync Google Calendar | Verificação bidirecional já validada separadamente | Não precisa testar a cada vez |
| Execução interna do N8N | Sem API de leitura de executions no dev | Só vemos input → output |
| Audit trail de edições | Banco não tem `updated_at` nem trigger de auditoria | Impossível ver histórico de mudanças |

---

## Bugs confirmados por esta bateria

| Bug | Severidade | Evidência |
|-----|-----------|-----------|
| **UPDATE de valor não altera o banco** | CRÍTICO | T1: IA disse R$55, T4 deletou R$47 |
| **UPDATE de nome não altera o banco** | CRÍTICO | T2: IA disse Pizzaria, T4 deletou Pizza |
| **UPDATE de data de evento não altera o banco** | CRÍTICO | T6: IA disse dia 27, banco mostra dia 25 |
| **Categoria da IA difere do banco** | MÉDIO | W2: IA disse "Renda Extra", banco tem "Outros" |
| **Consulta de saldo ignora entradas** | MÉDIO | W4: Saldo -R$33 ignorando Freelance R$150 |
| **Recorrente pode não criar se combinada** | BAIXO | T7: Sistema pediu confirmação, não criou |
