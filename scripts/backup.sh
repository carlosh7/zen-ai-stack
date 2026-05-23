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
docker run --rm -v ollama_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/ollama_data.tar.gz -C /data . 2>/dev/null && ok "ollama_data backed up" || warn "Could not backup ollama_data"
docker run --rm -v open-webui_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/open-webui_data.tar.gz -C /data . 2>/dev/null && ok "open-webui_data backed up" || warn "Could not backup open-webui_data"
docker run --rm -v portainer_data:/data -v "${BACKUP_DIR}:/backup" alpine tar czf /backup/portainer_data.tar.gz -C /data . 2>/dev/null && ok "portainer_data backed up" || warn "Could not backup portainer_data"

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
