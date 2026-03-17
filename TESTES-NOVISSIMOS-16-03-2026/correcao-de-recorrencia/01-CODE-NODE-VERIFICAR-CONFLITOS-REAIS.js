// ============================================================
// CODE NODE: "Verificar Conflitos Reais (Per-Event)"
//
// FUNCIONALIDADE:
// Substitui o node "Eh Conflito Real?" (If node).
// Em vez de comparar por NOME, faz verificação de overlap
// REAL entre cada evento novo e cada evento existente.
//
// COMO FUNCIONA:
// 1. Pega a lista de eventos novos do batch (do Switch2)
// 2. Pega os resultados da query do Supabase (input deste node)
// 3. Para cada evento existente, verifica se há overlap TEMPORAL
//    com algum evento novo específico
// 4. Retorna apenas os conflitos reais (com detalhes)
//
// ONDE COLOCAR:
// - Criar um novo Code node
// - Conectar a SAÍDA do "Buscar Conflitos (Batch)" na ENTRADA deste node
// - A saída deste node vai para um IF que checa se tem conflito
//
// IMPORTANTE: Este node SUBSTITUI o "Eh Conflito Real?" (If node)
// ============================================================

const eventosExistentes = $input.all().map(i => i.json);
const novosEventos = $('Switch2').first().json.parsed_output.tool;
const userId = $('setar_user').first().json.id_user;

// Array para guardar conflitos confirmados
const conflitosReais = [];

// Set para evitar duplicatas (mesmo evento existente contado 2x)
const idsJaContados = new Set();

for (const existente of eventosExistentes) {
  // Pular resultados vazios (quando Supabase retorna sem dados)
  if (!existente.id) continue;

  // Pular se já contamos este evento
  if (idsJaContados.has(existente.id)) continue;

  const existStart = new Date(existente.start_event).getTime();
  const existEnd = new Date(existente.end_event).getTime();

  for (const novo of novosEventos) {
    const novoStart = new Date(novo.data_inicio_evento).getTime();
    const novoEnd = new Date(novo.data_fim_evento).getTime();

    // Regra de overlap: dois intervalos se sobrepõem quando
    // um começa ANTES do outro terminar E termina DEPOIS do outro começar
    const temOverlap = existStart < novoEnd && existEnd > novoStart;

    if (temOverlap) {
      idsJaContados.add(existente.id);
      conflitosReais.push({
        conflito: true,
        evento_existente_id: existente.id,
        evento_existente_nome: existente.event_name,
        evento_existente_start: existente.start_event,
        evento_existente_end: existente.end_event,
        conflita_com_novo: novo.nome_evento,
        novo_start: novo.data_inicio_evento,
        novo_end: novo.data_fim_evento
      });
      break; // Um match basta — pula pro próximo existente
    }
  }
}

// Se não há conflitos, retorna flag de sem conflito
if (conflitosReais.length === 0) {
  return [{ json: { conflito: false, mensagem: "Nenhum conflito real detectado." } }];
}

// Retorna a lista de conflitos reais
return conflitosReais.map(c => ({ json: c }));
