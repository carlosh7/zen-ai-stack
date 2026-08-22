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
# Descubre los volúmenes reales del proyecto (los nombres llevan prefijo del
# proyecto compose, ej: zen-ai-stack_ollama_data). Antes se usaban nombres
# fijos sin prefijo y los backups salían vacíos reportando éxito.
ZEN_PROJECT="${ZEN_PROJECT:-zen-ai-stack}"
export ZEN_PROJECT
while IFS= read -r vol; do
    [ -z "$vol" ] && continue
    short="${vol#"${ZEN_PROJECT}"_}"
    if docker run --rm -v "$vol":/data -v "${BACKUP_DIR}:/backup" alpine tar czf "/backup/${short}.tar.gz" -C /data . 2>/dev/null; then
        ok "${short} backed up (${vol})"
    else
        warn "Could not backup ${vol}"
    fi
done < <(docker volume ls --filter "label=com.docker.compose.project=${ZEN_PROJECT}" --format '{{.Name}}')

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
