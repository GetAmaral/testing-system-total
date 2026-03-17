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
// 3. FILTRA eventos que acabaram de ser criados neste mesmo batch
//    (auto-conflito) comparando nome + horário exato
// 4. Para cada evento RESTANTE, verifica overlap TEMPORAL real
//    com algum evento novo específico
// 5. Retorna apenas os conflitos reais (com detalhes)
//
// ONDE COLOCAR:
// - Criar um novo Code node
// - Conectar a SAÍDA do "Buscar Conflitos (Batch)" na ENTRADA deste node
// - A saída deste node vai para um IF que checa se tem conflito
//
// IMPORTANTE: Este node SUBSTITUI o "Eh Conflito Real?" (If node)
//
// CORREÇÕES APLICADAS:
// - Fix auto-conflito: ignora eventos recém-criados pelo mesmo batch
// - Fix UTC: todas as comparações usam timestamps absolutos (sem timezone)
// ============================================================

const eventosExistentes = $input.all().map(i => i.json);
const novosEventos = $('Switch2').first().json.parsed_output.tool;

// ---------------------------------------------------------------
// PASSO 1: Montar "impressão digital" dos eventos do batch atual
// para excluir auto-conflitos (eventos que acabaram de ser criados
// pelo HTTP Create Tool6 e já aparecem no Supabase).
//
// Compara nome + start + end com tolerância de 60s para cobrir
// pequenas diferenças de arredondamento entre o que foi enviado
// e o que o Supabase gravou.
// ---------------------------------------------------------------
const TOLERANCIA_MS = 60 * 1000; // 60 segundos

function normalizarNome(nome) {
  return (nome || '').trim().toLowerCase();
}

function ehAutoConflito(existente, novosEventos) {
  const existNome = normalizarNome(existente.event_name);
  const existStart = new Date(existente.start_event).getTime();
  const existEnd = new Date(existente.end_event).getTime();

  for (const novo of novosEventos) {
    const novoNome = normalizarNome(novo.nome_evento);
    const novoStart = new Date(novo.data_inicio_evento).getTime();
    const novoEnd = new Date(novo.data_fim_evento).getTime();

    const nomeIgual = existNome === novoNome;
    const startProximo = Math.abs(existStart - novoStart) <= TOLERANCIA_MS;
    const endProximo = Math.abs(existEnd - novoEnd) <= TOLERANCIA_MS;

    // Se nome, start e end batem → é o próprio evento recém-criado
    if (nomeIgual && startProximo && endProximo) {
      return true;
    }
  }
  return false;
}

// ---------------------------------------------------------------
// PASSO 2: Verificar overlap real entre eventos EXTERNOS e novos
// ---------------------------------------------------------------
const conflitosReais = [];
const idsJaContados = new Set();

for (const existente of eventosExistentes) {
  // Pular resultados vazios (quando Supabase retorna sem dados)
  if (!existente.id) continue;

  // Pular se já contamos este evento
  if (idsJaContados.has(existente.id)) continue;

  // FILTRO ANTI AUTO-CONFLITO: pular eventos que acabaram de ser criados
  if (ehAutoConflito(existente, novosEventos)) continue;

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
