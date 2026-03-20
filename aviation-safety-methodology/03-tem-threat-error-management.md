# 03 — TEM & LOSA: Threat and Error Management + Line Operations Safety Audit

> Framework operacional para gerenciar ameaças e erros em tempo real,
> e a ferramenta de auditoria que coleta dados sobre ele.

---

## Parte A: TEM — Threat and Error Management

### 1. Definição

TEM é "um conceito abrangente de segurança para operações de aviação e desempenho humano" que assume que pilotos naturalmente cometerão erros e encontrarão situações de risco durante operações de voo. Em vez de tentar eliminar esses problemas, seu foco principal é **ensinar pilotos a gerenciá-los** para que não comprometam a segurança.

### 2. Contexto Histórico

- **Desenvolvido em 1994** por psicólogos da University of Texas at Austin
- Baseado em investigação de acidentes de companhias aéreas de grande capacidade
- Parceria entre University of Texas e Delta Airlines (1994)
- Primeiro LOSA baseado em TEM: Continental Airlines (1996)

### 3. Os Três Componentes Centrais

#### 3.1 Ameaças (Threats)
> "Eventos ou erros que ocorrem além da influência da tripulação, aumentam a complexidade operacional e devem ser gerenciados para manter as margens de segurança."

**Ameaças ambientais:**
- Clima (tempestades, turbulência, gelo, vento de través)
- Terreno (montanhas, aeroportos em vales)
- Condições do aeroporto (pistas curtas, auxílios inoperantes)
- Questões ATC (controladores sobrecarregados, instruções ambíguas)

**Ameaças relacionadas à companhia:**
- Mau funcionamento da aeronave
- Pressão de programação (schedule pressure)
- Problemas com equipe de solo

#### 3.2 Erros (Errors)
> "Ações ou inações do pessoal de linha que levam a desvios das intenções ou expectativas organizacionais ou operacionais."

| Tipo de Erro | Descrição | Exemplo |
|-------------|-----------|---------|
| **Manuseio da aeronave** | Erros no controle físico | Velocidade incorreta na aproximação |
| **Procedimentais** | Desvio de SOPs | Pular item do checklist |
| **Comunicação** | Falha na troca de informação | Readback incorreto de instrução ATC |
| **Proficiência** | Falta de conhecimento/habilidade | Configuração incorreta de automação |
| **Decisão operacional** | Escolha inadequada | Continuar aproximação instabilizada |

**Erros não gerenciados frequentemente criam estados indesejados.**

#### 3.3 Estados Indesejados da Aeronave (Undesired Aircraft States — UAS)
> "Condições operacionais onde uma situação não intencional resulta em redução das margens de segurança."

- Representa frequentemente **o último estágio antes de um incidente ou acidente**
- Exemplos: configuração incorreta, altitude errada, desvio de velocidade, aproximação não estabilizada

### 4. As Três Camadas de Contramedidas

```
┌─────────────────────────────────────────┐
│  1. EVITAR                              │
│  Prevenir ameaças e erros de ocorrerem  │
│  (briefings, planejamento, SOPs)        │
├─────────────────────────────────────────┤
│  2. CAPTURAR                            │
│  Detectar erros antes que levem a UAS   │
│  (cross-check, checklists, monitoria)   │
├─────────────────────────────────────────┤
│  3. MITIGAR                             │
│  Gerenciar UAS para prevenir acidentes  │
│  (go-around, procedimentos emergência)  │
└─────────────────────────────────────────┘
```

### 5. Características do Framework

- **Descritivo:** Captura desempenho humano e do sistema realista em contextos operacionais normais
- **Diagnóstico:** Quantifica complexidade operacional em relação ao desempenho humano
- **Aplicável a:** Análise de evento único, identificação de padrões sistêmicos, requisitos de licenciamento, desenvolvimento de treinamento

---

## Parte B: LOSA — Line Operations Safety Audit

### 1. Definição

LOSA é "um programa estruturado de observação de atividades de linha de frente construído em torno do conceito TEM." Usa observadores treinados para coletar dados sobre comportamento do piloto e seu contexto situacional em voos "normais", a partir de assentos supranumerários na cabine de comando.

### 2. Contexto Histórico

- **Pesquisa inicial:** Esforço conjunto entre University of Texas at Austin e Continental Airlines, financiado pela FAA
- **Primeiro LOSA baseado em TEM:** Continental Airlines, 1996
- **Endosso ICAO (1999):** "A ferramenta primária para desenvolver contramedidas ao erro humano em operações de aviação"
- **Documento de referência:** ICAO Doc 9803

### 3. As 10 Características Essenciais

1. Observações **entre pares** (não gerência observando trabalhadores)
2. Observações durante **operações normais** (não check-rides ou avaliações)
3. Coleta de dados **anônima**
4. Manuseio de dados **confidencial**
5. **Não-punitivo** — nenhum risco para tripulações observadas
6. Patrocínio conjunto **gerência/sindicato de pilotos**
7. Métodos de coleta de dados **seguros**
8. Observadores **treinados e confiáveis**
9. Análise de dados **sistemática**
10. Feedback **baseado em dados** para operações

### 4. Como Funciona na Prática

```
1. Observadores treinados → voam no jumpseat em voos regulares
                              ↓
2. Registram e codificam → ameaças identificáveis
                           → como ameaças foram gerenciadas
                           → erros gerados
                           → técnicas de gerenciamento de erros
                           → comportamentos historicamente ligados a acidentes
                              ↓
3. Dados fornecem → indicadores de forças e fraquezas organizacionais
                              ↓
4. Resultados → identificam modelos de desempenho superior
              → geram contramedidas para erros operacionais
              → informam desenvolvimento de programas CRM
```

### 5. LOSA vs. Auditoria Tradicional

| Aspecto | Auditoria Tradicional | LOSA |
|---------|----------------------|------|
| **Foco** | Conformidade com regras | Comportamento real em operação |
| **Ambiente** | Artificial (check-ride) | Natural (voo normal) |
| **Consequência** | Pode ser punitiva | Sempre não-punitiva |
| **Dados** | Individual | Agregados, anônimos |
| **Objetivo** | Aprovação/reprovação | Aprendizado organizacional |

---

## Relação TEM ↔ LOSA

O TEM é o **framework conceitual**. O LOSA é a **ferramenta de coleta de dados** que operacionaliza o TEM em observações do mundo real. TEM diz *o que observar*; LOSA diz *como observar*.

---

## Fontes

- SKYbrary — [Threat and Error Management](https://skybrary.aero/articles/threat-and-error-management-tem)
- SKYbrary — [TEM in Flight Operations](https://skybrary.aero/articles/threat-and-error-management-tem-flight-operations)
- SKYbrary — [LOSA](https://skybrary.aero/articles/line-operations-safety-audit-losa)
- ICAO Doc 9803 — [LOSA Methodology](https://www.losacollaborative.com/wp-content/uploads/2021/02/ICAO-Document-9803-LOSA.pdf)
- University of Texas Human Factors Research Project
