#!/usr/bin/env bash
# uninstall.sh — Remove zen-ai-stack completely
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
export ZEN_DIR ZEN_SCRIPT_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"

echo "┌─────────────────────────────────────────────────────────┐"
echo "│ ⚠️  This will REMOVE zen-ai-stack completely            │"
echo "│                                                         │"
echo "│  This will:                                             │"
echo "│  - Stop all Docker containers                           │"
echo "│  - Remove all Docker volumes (models, chats, images)    │"
echo "│  - Remove OpenCode config                               │"
echo "│  - Leave VS Code, Antigravity, Git, Docker untouched    │"
echo "└─────────────────────────────────────────────────────────┘"

if ! confirm "Uninstall zen-ai-stack?"; then
    log "Uninstall cancelled"
    exit 0
fi

log "Stopping Docker stack..."
cd "$ZEN_DIR"
docker compose down -v 2>/dev/null && ok "Docker stack stopped and volumes removed" || warn "No Docker stack found"

log "Removing OpenCode config..."
if [ -f "$HOME/.config/opencode/opencode.json.bak" ]; then
    mv "$HOME/.config/opencode/opencode.json.bak" "$HOME/.config/opencode/opencode.json" 2>/dev/null
    warn "OpenCode config restored from backup"
fi

log "Removing zen-ai-stack directory..."
cd "$HOME"
rm -rf "$ZEN_DIR"
ok "zen-ai-stack removed"

echo
echo "✅ Uninstall complete."
echo "  Docker, VS Code, Git, Antigravity remain installed."
echo "  OpenCode config restored from backup (if existed)."
