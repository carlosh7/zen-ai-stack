#!/usr/bin/env bash
# update.sh — Update zen-ai-stack stack and models
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
ZEN_LOG_DIR="${ZEN_LOG_DIR:-$HOME/.zen-ai-stack}"
export ZEN_DIR ZEN_SCRIPT_DIR ZEN_LOG_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"
source "$ZEN_SCRIPT_DIR/lib/docker.sh"

init_log
log "zen-ai-stack update"

log "Pulling latest Docker images..."
docker compose -f "$ZEN_DIR/docker-compose.yml" pull
ok "Images updated"

log "Recreating containers..."
docker compose -f "$ZEN_DIR/docker-compose.yml" up -d --force-recreate
ok "Containers recreated"

wait_for_ollama 120

log "Updating models..."
OLLAMA_MODELS="${OLLAMA_MODELS:-qwen2.5-coder:7b,qwen2.5-vl:7b,llama3.2:3b,nomic-embed-text}"
pull_models "$OLLAMA_MODELS"

log "Updating OpenCode..."
if [ -f "$HOME/.opencode/bin/opencode" ]; then
    if curl -fsSL https://opencode.ai/install | bash 2>/dev/null; then
        ok "OpenCode updated"
    else
        warn "OpenCode update failed"
    fi
fi

ok "zen-ai-stack updated successfully"
