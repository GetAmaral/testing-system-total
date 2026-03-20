# 01 — Modelo do Queijo Suíço (Swiss Cheese Model)

> Modelo de causação de acidentes criado por James Reason.
> Fundamento teórico de toda a segurança moderna na aviação.

---

## 1. Definição

O Modelo do Queijo Suíço compara os sistemas de defesa de uma organização a **fatias de queijo suíço empilhadas lado a lado**. Cada fatia representa uma camada de defesa (treinamento, procedimentos, automação, supervisão, etc.). Os **buracos** em cada fatia representam falhas ou fraquezas naquela camada.

Um acidente ocorre **somente quando os buracos de todas as fatias se alinham momentaneamente**, criando uma "trajetória de oportunidade de acidente" que permite que um perigo atravesse todas as camadas de defesa.

**Implicação fundamental:** Nenhuma falha isolada é suficiente para causar um acidente em um sistema bem defendido. Acidentes requerem o alinhamento simultâneo de múltiplas falhas em múltiplas camadas.

---

## 2. Contexto Histórico

### James Reason (1938–2025)

- **Nome completo:** James Tootle Reason CBE
- **Nascimento:** 1 de maio de 1938
- **Falecimento:** 4 de fevereiro de 2025 (86 anos)
- **Instituição:** Professor de Psicologia na University of Manchester (graduação em 1962, professor titular de 1977 a 2001)
- **Publicação do modelo:** Introduzido em 1990 no livro seminal *Human Error*
- **Desenvolvimento:** Expandido em *Managing the Risks of Organizational Accidents* (1997)
- **Alcance:** Mais de 280 apresentações em Europa, EUA, Canadá, México, Oriente Médio, África, Sudeste Asiático, Japão, Hong Kong, Austrália e Nova Zelândia
- **Reconhecimento:** Doutorado honorário pela University of Aberdeen (2003)
- **Contexto pessoal:** Seu pai foi morto durante o Blitz de Londres; sua mãe faleceu alguns anos depois. Foi criado pelo avô materno, Thomas Reason, cujo sobrenome adotou.

---

## 3. Os Quatro Níveis de Falha

O modelo organiza as falhas em quatro níveis hierárquicos, do mais distante ao mais próximo do evento:

### Nível 4 — Influências Organizacionais (mais distante)
- Decisões corporativas e alocação de recursos
- Cultura e clima organizacional
- Políticas e processos operacionais

### Nível 3 — Supervisão Insegura
- Supervisão inadequada (falta de orientação, treinamento, liderança)
- Operações planejadas de forma inadequada (aceitação de risco inaceitável)
- Falha em corrigir problemas conhecidos
- Violações supervisórias

### Nível 2 — Precondições para Atos Inseguros
- Estados mentais adversos (complacência, estresse, perda de consciência situacional)
- Estados fisiológicos adversos (fadiga, doença, intoxicação)
- Limitações físicas/mentais
- Falhas de CRM (comunicação, coordenação)
- Fatores ambientais (físicos e tecnológicos)

### Nível 1 — Atos Inseguros (mais próximo do evento)
- **Erros** (não intencionais): baseados em habilidade, decisão, percepção
- **Violações** (intencionais): rotineiras e excepcionais

---

## 4. Falhas Ativas vs. Condições Latentes

| Aspecto | Falhas Ativas | Condições Latentes |
|---------|---------------|-------------------|
| **Onde ocorrem** | Na "ponta afiada" — operadores em contato direto com o sistema | Nos níveis organizacionais e supervisórios |
| **Quando se manifestam** | Efeito imediato | Podem permanecer dormentes por dias, semanas ou meses |
| **Quem comete** | Pilotos, controladores, técnicos | Gerentes, projetistas, reguladores |
| **Exemplos** | Esquecimento de checklist, erro de comunicação | Cultura de pressão, treinamento insuficiente, recursos inadequados |
| **Detecção** | Geralmente óbvia após o fato | Difícil de detectar antes que contribua para um acidente |

**Insight crítico:** As condições latentes são os "residentes patógenos" do sistema — existem antes do acidente e criam as condições para que as falhas ativas ocorram.

---

## 5. Camadas de Defesa na Aviação

1. **Barreiras de engenharia** — Salvaguardas físicas, alarmes, desligamentos automáticos
2. **Projeto do espaço aéreo** — Separação de rotas, altitudes mínimas
3. **Controle de Tráfego Aéreo** — Monitoramento e separação
4. **Licenciamento e treinamento** — Qualificação de pilotos e tripulação
5. **Procedimentos operacionais padrão (SOPs)** — Padronização de ações
6. **Checklists** — Verificação sistemática de itens críticos
7. **Sistemas de manutenção** — Inspeções programadas e corretivas

---

## 6. Casos Reais

### Desastre de Tenerife (1977) — 583 mortos
- **Camada 1 (Ambiente):** Nevoeiro denso reduziu visibilidade
- **Camada 2 (Comunicação):** Comunicação não-padrão com ATC
- **Camada 3 (Autoridade):** Gradiente de autoridade — Capitão da KLM ignorou preocupações do Copiloto e do Engenheiro de Voo
- **Camada 4 (ATC):** Miscomunicação sobre autorização de decolagem
- **Resultado:** Todos os buracos se alinharam → colisão na pista

### Chernobyl (1986)
- Cultura de segurança inadequada + falta de treinamento + equipamento obsoleto + pressão gerencial = fusão nuclear catastrófica

### BP Deepwater Horizon (2010)
- Múltiplas falhas organizacionais, supervisórias e operacionais alinhadas simultaneamente

---

## 7. Aplicação Prática — Como Prevenir Alinhamento

1. **Redundância:** Múltiplas camadas de defesa independentes
2. **Detecção de condições latentes:** Auditorias proativas, LOSA, FDM
3. **Cultura de reporte:** Sistemas como ASRS/ASAP que incentivam denúncia sem punição
4. **Treinamento contínuo:** CRM, TEM, simuladores
5. **Análise sistêmica:** Investigar além do ato inseguro — buscar as condições latentes

**Princípio central:** Se em qualquer ponto antes do evento adverso uma das falhas for corrigida, o acidente será prevenido.

---

## 8. Críticas e Limitações

- O modelo pode simplificar excessivamente interações complexas entre fatores
- A metáfora do "queijo" sugere que os buracos são estáticos, quando na realidade são dinâmicos
- Foco excessivo em falhas pode negligenciar como os sistemas normalmente têm sucesso (crítica da Engenharia de Resiliência)
- Reason reconheceu estas limitações e o modelo evoluiu ao longo de suas publicações

---

## Fontes

- Reason, J. (1990). *Human Error*. Cambridge University Press.
- Reason, J. (1997). *Managing the Risks of Organizational Accidents*. Ashgate.
- SKYbrary — [James Reason HF Model](https://skybrary.aero/articles/james-reason-hf-model)
- Wikipedia — [Swiss cheese model](https://en.wikipedia.org/wiki/Swiss_cheese_model)
- Wikipedia — [James Reason](https://en.wikipedia.org/wiki/James_Reason)
- Flight Safety Australia — [The absent-minded professor who made a safer world](https://www.flightsafetyaustralia.com/2025/02/the-absent-minded-professor-who-made-a-safer-world/)
- Segurança do Trabalho NWN — [Teoria do Queijo Suíço](https://segurancadotrabalhonwn.com/teoria-do-queijo-suico/)
