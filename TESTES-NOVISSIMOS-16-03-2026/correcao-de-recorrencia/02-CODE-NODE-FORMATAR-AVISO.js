// ============================================================
// CODE NODE: "Formatar Aviso de Conflito"
//
// FUNCIONALIDADE:
// Monta a mensagem de aviso de conflito para enviar ao
// usuário via WhatsApp. Inclui detalhes de QUAL evento
// existente conflita com QUAL evento novo, com datas
// formatadas em pt-BR.
//
// ONDE COLOCAR:
// - Conectar DEPOIS do Aggregate que junta os conflitos reais
// - A saída vai para o node de envio WhatsApp (Aviso Conflito)
//
// DIFERENÇA DO ATUAL:
// Antes: listava apenas nomes dos eventos existentes
// Agora: mostra pares (evento existente ↔ evento novo) com horários
// ============================================================

const conflitos = $input.all().map(i => i.json);

// Se veio do path sem conflito, não faz nada
if (conflitos.length === 1 && conflitos[0].conflito === false) {
  return [{ json: { tem_conflito: false } }];
}

// Função auxiliar para formatar data ISO → "17/03/2026 10:00"
function formatarData(isoString) {
  if (!isoString) return '(sem data)';
  try {
    const d = new Date(isoString);
    const dia = String(d.getDate()).padStart(2, '0');
    const mes = String(d.getMonth() + 1).padStart(2, '0');
    const ano = d.getFullYear();
    const hora = String(d.getHours()).padStart(2, '0');
    const min = String(d.getMinutes()).padStart(2, '0');
    return `${dia}/${mes}/${ano} ${hora}:${min}`;
  } catch (e) {
    return isoString;
  }
}

// Montar linhas de detalhe
const linhas = conflitos.map(c => {
  const existNome = c.evento_existente_nome || 'Sem título';
  const existHora = formatarData(c.evento_existente_start);
  const novoNome = c.conflita_com_novo || 'Novo evento';
  const novoHora = formatarData(c.novo_start);
  return `- *${existNome}* (${existHora}) conflita com *${novoNome}* (${novoHora})`;
});

const mensagem = `⚠️ *Atenção — conflitos detectados:*\n\n${linhas.join('\n')}\n\nVerifique sua agenda.`;

return [{
  json: {
    tem_conflito: true,
    mensagem_conflito: mensagem,
    total_conflitos: conflitos.length
  }
}];
