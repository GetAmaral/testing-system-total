# Configuração Corrigida — Node "Set Range (Batch)"

## O que este node faz

Prepara os parâmetros para a query de conflitos. O range (min/max) ainda é usado para a query do Supabase (para não fazer N queries), mas agora também passa o **array completo de eventos** para que o Code node possa fazer a verificação per-event.

## O que muda

- **MANTÉM** `range_start` e `range_end` (a query do Supabase ainda precisa)
- **REMOVE** `nomes_batch` (não é mais usado — a verificação agora é por horário, não por nome)
- **ADICIONA** `eventos_novos_json` com os dados completos de cada evento

---

## Configuração do node (ctrl+c ctrl+v nos campos)

### Assignment 1 — user_id (sem mudança)
```
Name:  user_id
Type:  String
Value: {{ $('setar_user').first().json.id_user }}
```

### Assignment 2 — range_start (sem mudança)
```
Name:  range_start
Type:  String
Value: {{ $('Switch2').first().json.parsed_output.tool.map(t => t.data_inicio_evento).filter(Boolean).sort()[0] }}
```

### Assignment 3 — range_end (sem mudança)
```
Name:  range_end
Type:  String
Value: {{ $('Switch2').first().json.parsed_output.tool.map(t => t.data_fim_evento).filter(Boolean).sort().reverse()[0] }}
```

### Assignment 4 — eventos_novos_json (NOVO)
```
Name:  eventos_novos_json
Type:  String
Value: {{ JSON.stringify($('Switch2').first().json.parsed_output.tool) }}
```

### Assignment 5 — nomes_batch
**DELETAR ESTE CAMPO** — não é mais necessário. A verificação agora é temporal, não por nome.

---

## Por que a mudança

O `nomes_batch` era usado no antigo "Eh Conflito Real?" para filtrar por nome. Isso causava:
1. Falsos negativos: evento com mesmo nome mas horário diferente era ignorado
2. Falsos positivos: evento com nome diferente mas sem overlap era flagado

O `eventos_novos_json` permite que o Code node faça verificação de overlap real.
