# Query Supabase Corrigida — Node "Buscar Conflitos (Batch)"

## O que este node faz

Busca no Supabase TODOS os eventos existentes do usuário que caem dentro do range temporal do batch. Isso é uma **pré-filtragem** — o Code node depois verifica quais realmente conflitam.

## O que muda

A query em si continua a mesma, **MAS** adicionamos um filtro para excluir eventos que foram RECÉM-CRIADOS nesta mesma execução (se a criação acontecer antes da checagem).

---

## Opção A — Se você inverter a ordem (criar DEPOIS de checar) — RECOMENDADO

A query NÃO precisa mudar. Use exatamente como está:

```
Filter String (ctrl+c ctrl+v):

user_id=eq.{{ $json.user_id }}&start_event=lt.{{ $json.range_end }}&end_event=gt.{{ $json.range_start }}&select=id,event_name,start_event,end_event
```

Nenhuma mudança necessária — como os eventos ainda não foram criados, eles não aparecem na query.

---

## Opção B — Se mantiver a ordem atual (criar ANTES de checar)

Precisa excluir os eventos recém-criados. Para isso:

### Passo 1: Capturar os IDs retornados pelo HTTP - Create Calendar Tool6

Adicionar um **Set node** depois do `HTTP - Create Calendar Tool6` para extrair os IDs:

```
Name:  ids_recem_criados
Type:  String
Value: {{ $input.all().map(i => i.json.id || i.json.data?.id).filter(Boolean).join(',') }}
```

### Passo 2: Modificar a query do Supabase

```
Filter String (ctrl+c ctrl+v):

user_id=eq.{{ $json.user_id }}&start_event=lt.{{ $json.range_end }}&end_event=gt.{{ $json.range_start }}&id=not.in.({{ $json.ids_recem_criados }})&select=id,event_name,start_event,end_event
```

O trecho `&id=not.in.(...)` exclui os IDs que acabaram de ser criados.

---

## Configurações do node (manter como estão)

| Campo | Valor |
|-------|-------|
| Operation | Get All |
| Table | calendar |
| Return All | true |
| Filter Type | String |
| Always Output Data | **true** (importante — garante que o node seguinte recebe dados mesmo sem resultados) |
