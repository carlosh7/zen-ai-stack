#!/usr/bin/env bash
# backup.sh — Backup zen-ai-stack configurations
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
BACKUP_DIR="${BACKUP_DIR:-$HOME/zen-ai-stack-backups/$(date +%Y%m%d_%H%M%S)}"
export ZEN_DIR ZEN_SCRIPT_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"

init_log
log "Backing up to: ${BACKUP_DIR}"
mkdir -p "$BACKUP_DIR"

log "Backing up Docker volumes..."
if docker run --rm -v ollama_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/ollama_data.tar.gz -C /data . 2>/dev/null; then
    ok "ollama_data backed up"
else
    warn "Could not backup ollama_data"
fi
if docker run --rm -v open-webui_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/open-webui_data.tar.gz -C /data . 2>/dev/null; then
    ok "open-webui_data backed up"
else
    warn "Could not backup open-webui_data"
fi
if docker run --rm -v portainer_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/portainer_data.tar.gz -C /data . 2>/dev/null; then
    ok "portainer_data backed up"
else
    warn "Could not backup portainer_data"
fi

log "Backing up ComfyUI assets (bind mounts)..."
[ -d "$ZEN_DIR/comfyui/models" ] && tar czf "$BACKUP_DIR/comfyui_models.tar.gz" -C "$ZEN_DIR/comfyui" models/ 2>/dev/null && ok "comfyui models backed up" || warn "Could not backup comfyui models"
[ -d "$ZEN_DIR/comfyui/output" ] && tar czf "$BACKUP_DIR/comfyui_output.tar.gz" -C "$ZEN_DIR/comfyui" output/ 2>/dev/null && ok "comfyui output backed up" || warn "Could not backup comfyui output"
[ -d "$ZEN_DIR/comfyui/workflows" ] && tar czf "$BACKUP_DIR/comfyui_workflows.tar.gz" -C "$ZEN_DIR/comfyui" workflows/ 2>/dev/null && ok "comfyui workflows backed up" || warn "Could not backup comfyui workflows"

log "Backing up configuration files..."
[ -f "$ZEN_DIR/.env" ] && cp "$ZEN_DIR/.env" "$BACKUP_DIR/" && ok ".env backed up"
[ -f "$HOME/.config/opencode/opencode.json" ] && cp "$HOME/.config/opencode/opencode.json" "$BACKUP_DIR/" && ok "opencode.json backed up"
[ -f "$ZEN_DIR/docker-compose.yml" ] && cp "$ZEN_DIR/docker-compose.yml" "$BACKUP_DIR/" && ok "docker-compose.yml backed up"

log "Backing up custom configs..."
[ -d "$ZEN_DIR/configs" ] && cp -r "$ZEN_DIR/configs" "$BACKUP_DIR/" && ok "configs backed up"

ok "Backup complete: ${BACKUP_DIR}"
echo
echo "To restore:"
echo "  docker run --rm -v volume:/data -v ${BACKUP_DIR}:/backup alpine tar xzf /backup/volume_data.tar.gz -C /data"
