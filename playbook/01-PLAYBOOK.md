# Playbook — Processo Completo de Mudanca e Deploy

## Fase 0: Planejamento (antes de tocar em qualquer coisa)

**Pergunta**: O que voce vai fazer?

```
[ ] Descrevi o que vou mudar (mesmo que mentalmente)
[ ] Sei quais workflows vao ser afetados
[ ] Sei por que estou fazendo essa mudanca
```

**Tempo**: 2 minutos

---

## Fase 1: Snapshot ANTES

**Objetivo**: Tirar uma foto do estado atual do DEV antes de mexer em qualquer coisa.

```
@guardian
*snapshot pre-{nome-descritivo}
```

**Exemplos de labels bons**:
- `pre-filtro-categoria` (antes de adicionar filtro)
- `pre-fix-calendario` (antes de corrigir bug do calendario)
- `pre-v3.2` (antes de comecar versao 3.2)
- `pre-refactor-prompts` (antes de refatorar prompts)

**O que acontece**:
- Vigil exporta todos os 6 workflows do DEV
- Salva JSONs limpos (sem pinData) em `data/snapshots/`
- Registra no historico

```
[ ] Snapshot ANTES capturado com sucesso
[ ] Label descritivo e claro
```

**Tempo**: 1 minuto

---

## Fase 2: Mudanca no DEV

**Objetivo**: Fazer suas mudancas no N8N DEV.

Abra o N8N DEV: `http://76.13.172.17:5678`

Faca o que precisa:
- Adicionar nodes
- Mudar prompts
- Alterar conexoes
- Corrigir bugs
- Testar manualmente no editor

```
[ ] Mudancas feitas no N8N DEV
[ ] Testei manualmente no editor (clicou "Test Workflow")
[ ] Parece funcionar no DEV
```

**Tempo**: varia (minutos a horas)

---

## Fase 3: Snapshot DEPOIS

**Objetivo**: Tirar foto do estado novo do DEV.

```
*snapshot pos-{mesmo-nome}
```

Exemplo: se o snapshot anterior foi `pre-filtro-categoria`, agora e `pos-filtro-categoria`.

```
[ ] Snapshot DEPOIS capturado com sucesso
```

**Tempo**: 1 minuto

---

## Fase 4: Diff — O que mudou?

**Objetivo**: Ver exatamente o que mudou entre antes e depois.

```
*diff --latest
```

**O que voce deve verificar no diff**:
- Os workflows que mudaram sao os que voce esperava?
- As mudancas sao as que voce fez? (nenhuma mudanca inesperada?)
- O risco geral e aceitavel?

```
[ ] Diff gerado
[ ] Revi as mudancas — sao as que eu esperava
[ ] Nenhuma mudanca inesperada
[ ] Risco geral anotado: _________ (LOW/MEDIUM/HIGH/CRITICAL)
```

**Se encontrou mudanca inesperada**: PARE. Investigue antes de continuar.

**Tempo**: 5 minutos

---

## Fase 5: Spec — Documentar a mudanca

**Objetivo**: Registrar O QUE mudou e POR QUE. Criar criterios de aceite.

```
*spec "descricao curta da mudanca"
```

O Vigil vai te perguntar:
1. O que voce mudou (em linguagem natural)
2. Por que mudou
3. Quais workflows foram afetados

```
[ ] Spec criada com descricao clara
[ ] Criterios de aceite fazem sentido
[ ] Features impactadas estao corretas
```

**Tempo**: 3-5 minutos

---

## Fase 6: Teste — Funciona?

**Objetivo**: Testar as mudancas contra os criterios da spec.

```
*audit-spec --auto
```

O Vigil delega testes para o Watson e a Lupa, depois avalia:
- Funciona? Util? Escalavel? Performance OK? Seguro?

**Veredictos possiveis**:

| Veredicto | Significado | Acao |
|-----------|-------------|------|
| **GO** | Tudo OK | Pode prosseguir para deploy |
| **CONDICIONAL** | Funciona mas tem ressalvas | Avaliar se vale deployar agora |
| **NO-GO** | Tem problemas | Voltar para Fase 2 e corrigir |

```
[ ] Teste executado
[ ] Veredicto: _________ (GO / CONDICIONAL / NO-GO)
[ ] Se CONDICIONAL: avaliei as ressalvas e decidi prosseguir? (sim/nao)
[ ] Se NO-GO: voltei para Fase 2 para corrigir
```

**Tempo**: 5-15 minutos

---

## Fase 7: Checklist de Deploy — O que corrigir?

**Objetivo**: Gerar a lista COMPLETA de correcoes necessarias para levar do DEV ao PROD.

```
*pre-deploy
```

O Vigil escaneia TUDO e gera um checklist com:
- Cada URL de DEV que precisa virar PROD
- Cada credential que precisa trocar
- Nodes fake do WhatsApp que precisa remover
- pinData que precisa limpar
- Total de correcoes

```
[ ] Checklist gerado
[ ] Li o checklist inteiro (nao pulei nada)
[ ] Total de correcoes: _____ itens
[ ] Entendo cada correcao listada
```

**Tempo**: 2-5 minutos

---

## Fase 8: Deploy Manual

**Objetivo**: Aplicar as correcoes e importar workflows para PROD.

**SIGA O CHECKLIST ITEM POR ITEM.**

### Passos padrao:

```
[ ] 1. Pull do GitHub:
      cd /home/totalAssistente && git pull origin main

[ ] 2. Copiar JSONs para area de trabalho:
      cp -r jsons/ /tmp/deploy_n8n/

[ ] 3. Aplicar TODAS as correcoes do checklist nos JSONs:
      [ ] URLs de DEV → PROD (todas as ___ ocorrencias)
      [ ] Credential IDs trocados (todos os ___ nodes)
      [ ] WhatsApp trigger: nodes fake removidos + real adicionado
      [ ] pinData limpo em todos os workflows

[ ] 4. CONFERIR: marquei todos os ___ itens do checklist?
      Se nao → PARE e revise

[ ] 5. Desativar workflows em PROD (um por um):
      PUT /workflows/{id} com { "active": false }

[ ] 6. Importar JSONs corrigidos:
      PUT /workflows/{id} com JSON completo

[ ] 7. Reativar workflows:
      PUT /workflows/{id} com { "active": true }

[ ] 8. Verificar logs:
      docker logs totalassistente-n8n --tail 50
```

```
[ ] Deploy concluido
[ ] Todos os ___ itens do checklist marcados
```

**Tempo**: 15-30 minutos

---

## Fase 9: Validacao — PROD esta OK?

**Objetivo**: Confirmar que PROD esta funcionando e nao ficou nada de DEV.

```
*validate-prod
```

O Vigil pede ao Sherlock para escanear PROD:
- Containers rodando?
- Erros nos logs?
- URLs de DEV residuais?
- Credentials de DEV?
- WhatsApp trigger real?
- pinData limpo?
- Todos workflows ativos?

**Veredictos possiveis**:

| Veredicto | Significado | Acao |
|-----------|-------------|------|
| **ALL_CLEAR** | Tudo OK | Pronto! Deploy concluido! |
| **ISSUES_FOUND** | Problemas menores | Corrigir quando possivel, monitorar |
| **CRITICAL_FAILURE** | Problema grave | Rollback IMEDIATO |

```
[ ] Validacao executada
[ ] Veredicto: _________ (ALL_CLEAR / ISSUES_FOUND / CRITICAL_FAILURE)
[ ] Se ISSUES_FOUND: anotei os issues para corrigir
[ ] Se CRITICAL_FAILURE: executei rollback (ver Fase Emergencia)
```

**Tempo**: 5 minutos

---

## Fase 10: Registro

**Objetivo**: Documentar o que foi feito para historico.

```
[ ] Relatorios salvos em guardian-deploy/output/
[ ] Se encontrou bugs: anotado para corrigir
[ ] Se mudou algo nos data files: atualizar environments.yaml se necessario
```

**Tempo**: 2 minutos

---

## Resumo Visual da Esteira

```
 FASE 0        FASE 1         FASE 2        FASE 3        FASE 4
Planejar → Snapshot ANTES → Mudar DEV → Snapshot DEPOIS → Diff
                                                            |
                                                            v
 FASE 9        FASE 8         FASE 7        FASE 6        FASE 5
Validar  ← Deploy Manual ← Checklist  ←  Testar    ←    Spec
   |
   v
 FASE 10
Registrar → PRONTO!
```

---

## Tempos Estimados

| Fase | Tempo | Acumulado |
|------|-------|-----------|
| 0. Planejar | 2 min | 2 min |
| 1. Snapshot antes | 1 min | 3 min |
| 2. Mudanca DEV | varia | — |
| 3. Snapshot depois | 1 min | — |
| 4. Diff | 5 min | — |
| 5. Spec | 5 min | — |
| 6. Teste | 10 min | — |
| 7. Checklist | 3 min | — |
| 8. Deploy | 20 min | — |
| 9. Validacao | 5 min | — |
| 10. Registro | 2 min | — |
| **TOTAL (sem fase 2)** | **~55 min** | |

Parece muito? Sem a esteira, o tempo que voce gasta debugando um deploy quebrado e MUITO maior.
