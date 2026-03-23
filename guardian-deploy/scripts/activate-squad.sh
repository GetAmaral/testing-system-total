#!/bin/bash
# Guardian Deploy Squad - Activation Script
# Usage: source scripts/activate-squad.sh

SQUAD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "============================================"
echo "  Guardian Deploy Squad - Ativacao"
echo "============================================"
echo ""
echo "Squad: guardian-deploy"
echo "Dir:   $SQUAD_DIR"
echo ""
echo "Agente:"
echo "  Vigil (Guardian) - Copiloto de Deploy (READ-ONLY)"
echo ""
echo "Comandos:"
echo "  *snapshot [label]  - Capturar snapshot do DEV"
echo "  *diff [v1] [v2]   - Comparar versoes DEV"
echo "  *spec              - Criar spec de mudanca"
echo "  *audit-spec        - Testar contra spec"
echo "  *pre-deploy        - Gerar checklist GRANULAR"
echo "  *validate-prod     - Validar PROD pos-deploy"
echo "  *lifecycle         - Ciclo completo"
echo "  *help              - Ajuda"
echo ""
echo "Modo: DEV READ-ONLY | PROD via @analisador"
echo "NUNCA executa deploy — gera checklist para o humano."
echo "============================================"

# Criar output dirs se nao existem
mkdir -p "$SQUAD_DIR/output/specs"
mkdir -p "$SQUAD_DIR/output/diffs"
mkdir -p "$SQUAD_DIR/output/audits"
mkdir -p "$SQUAD_DIR/output/deploys"
mkdir -p "$SQUAD_DIR/data/snapshots"
mkdir -p "$SQUAD_DIR/config"

export GUARDIAN_DEPLOY_SQUAD_DIR="$SQUAD_DIR"
export GUARDIAN_DEPLOY_MODE="dev-read-prod-readonly"
