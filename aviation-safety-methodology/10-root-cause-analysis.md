# 10 — RCA: Root Cause Analysis (Análise de Causa Raiz)

> Métodos sistemáticos para ir além dos sintomas e encontrar
> por que as falhas realmente aconteceram.

---

## 1. Definição

Root Cause Analysis (RCA) é uma abordagem sistemática para identificar as causas subjacentes de acidentes e incidentes, indo **além dos sintomas imediatos** para descobrir por que as falhas ocorreram.

---

## 2. Método 1 — 5-Why (5 Porquês)

### Como Funciona
Questionamento repetitivo ("Por quê?") — tipicamente 5 iterações para chegar à causa raiz.

### Exemplo em Aviação

```
Aeronave pousa com combustível baixo
  └── Por quê? Tripulação não desviou para alternativa
       └── Por quê? Tripulação não sabia do estado de combustível
            └── Por quê? Procedimento de monitoramento de combustível não foi seguido
                 └── Por quê? SOP era ambíguo sobre frequência de verificação
                      └── Por quê? Não havia processo de revisão de SOPs
                           → CAUSA RAIZ: falta de governança de SOPs
```

### Vantagens
- Fácil de usar e ensinar
- Identifica múltiplas causas
- Útil para problemas diretos

### Limitações
- Pode parar cedo demais (aceitar causa superficial)
- Diferentes analistas podem chegar a conclusões diferentes
- Não mapeia interações complexas entre fatores

---

## 3. Método 2 — Fishbone / Ishikawa

### Contexto
- Desenvolvido por **Dr. Kaoru Ishikawa nos anos 1960**
- Ferramenta visual em formato de espinha de peixe
- Problema na "cabeça", categorias de causas formando as "espinhas"

### Categorias Padrão na Aviação (6M)

```
         Man (Fatores Humanos)
        /
Machine (Equipamento) ──── PROBLEMA ──── Method (Procedimentos)
        \                                /
         Materials ──────────── Milieu (Ambiente)
                                    \
                                     Management (Gestão)
```

| Categoria | Perguntas-Chave |
|-----------|----------------|
| **Man** | Treinamento adequado? Fadiga? Consciência situacional? |
| **Machine** | Equipamento funcionando? Design adequado? Manutenção em dia? |
| **Method** | SOPs claros? Checklists seguidos? Procedimentos atualizados? |
| **Materials** | Peças corretas? Documentação disponível? |
| **Milieu** | Clima? Iluminação? Pressão de tempo? |
| **Management** | Recursos adequados? Supervisão? Cultura organizacional? |

### Melhor Uso
Combinado com 5-Why: Fishbone identifica **categorias de causas potenciais**, 5-Why **aprofunda dentro de cada categoria**.

---

## 4. Método 3 — Fault Tree Analysis (FTA)

### Contexto
- Desenvolvido pelo **Bell Laboratories nos anos 1960 para a Força Aérea dos EUA**
- Análise de falhas top-down e dedutiva
- NASA publicou o "Fault Tree Handbook with Aerospace Applications"
- FAA Order 8040.4 (1998) estabeleceu política de gestão de risco incluindo FTA

### Como Funciona

Começa com o **evento indesejado no topo** e trabalha para baixo usando portas lógicas:

```
              [ACIDENTE]
                  |
             [OR Gate]
            /         \
    [Falha A]      [AND Gate]
                   /        \
           [Falha B]    [Falha C]
```

### Portas Lógicas

| Porta | Significado | Analogia |
|-------|-------------|----------|
| **OR** | Saída ocorre se QUALQUER entrada ocorrer | Qualquer causa única é suficiente |
| **AND** | Saída ocorre SOMENTE se TODAS as entradas ocorrerem | Todas as causas devem estar presentes |

### Vantagens
- Permite **cálculos de probabilidade** usando lógica booleana
- Visualiza **interações complexas** entre fatores
- Identifica **pontos de falha únicos** (single points of failure)
- Amplamente usado em aeroespacial, nuclear e processamento químico

---

## 5. Abordagem Combinada (Recomendada)

A melhor prática é usar múltiplos métodos juntos:

```
1. Fishbone → mapeia TODAS as categorias de causas potenciais
        ↓
2. 5-Why → aprofunda dentro de cada categoria relevante
        ↓
3. FTA → modela interações entre causas e calcula probabilidades
        ↓
4. Resultado → causa raiz identificada com evidências e lógica
```

---

## Fontes

- SAS Sofia — [Effective Aviation RCA Using 5-Why and Fishbone](https://sassofia.com/blog/effective-aviation-system-root-cause-analysis-using-5-why-fishbone-techniques-together/)
- Wikipedia — [Fault Tree Analysis](https://en.wikipedia.org/wiki/Fault_tree_analysis)
- NASA — [Fault Tree Handbook with Aerospace Applications](https://www.mwftr.com/CS2/Fault%20Tree%20Handbook_NASA.pdf)
