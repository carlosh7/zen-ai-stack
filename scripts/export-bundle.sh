#!/usr/bin/env bash
# export-bundle.sh — Create offline installation bundle for zen-ai-stack
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
export ZEN_DIR ZEN_SCRIPT_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"
source "$ZEN_SCRIPT_DIR/lib/bundle.sh"

init_log
log "zen-ai-stack bundle export"

BUNDLE_DIR="${1:-$ZEN_DIR/models-bundle}"
bundle_set_dir "$BUNDLE_DIR"

log "Created bundle directory: $BUNDLE_DIR"

bundle_export_docker_images
bundle_export_ollama_models
bundle_export_loras "$ZEN_DIR/comfyui/models/loras"
bundle_export_screenshot_to_code "$ZEN_DIR/tools/screenshot-to-code"
bundle_export_opencode
bundle_write_manifest

log "Creating archive..."
bundle_create_archive "${2:-$ZEN_DIR/models-bundle.tar.gz}"

echo
echo "┌─────────────────────────────────────────────────────────┐"
echo -e "│ ${GREEN}✅ Bundle created${NC}                                           │"
echo "│                                                         │"
echo "│  Bundle: ${BUNDLE_DIR}                    │"
echo "│  Archive: ${2:-$ZEN_DIR/models-bundle.tar.gz}           │"
echo "│  Size: $(du -sh "${2:-$ZEN_DIR/models-bundle.tar.gz}" | awk '{print $1}')                                 │"
echo "│                                                         │"
echo "│  To use on another machine:                             │"
echo "│  1. Copy models-bundle.tar.gz to target machine         │"
echo "│  2. Run: ./scripts/setup.sh --offline                   │"
echo "└─────────────────────────────────────────────────────────┘"
