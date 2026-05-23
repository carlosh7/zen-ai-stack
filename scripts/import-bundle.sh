#!/usr/bin/env bash
# import-bundle.sh — Restore zen-ai-stack from offline bundle
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
export ZEN_DIR ZEN_SCRIPT_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"
source "$ZEN_SCRIPT_DIR/lib/bundle.sh"

init_log
log "zen-ai-stack bundle import"

# Check arguments
ARCHIVE="${1:-$ZEN_DIR/models-bundle.tar.gz}"
BUNDLE_DIR="${2:-$ZEN_DIR/models-bundle}"

# If archive exists but bundle dir doesn't, extract it
if [ -f "$ARCHIVE" ] && [ ! -d "$BUNDLE_DIR" ]; then
    bundle_extract_archive "$ARCHIVE" "$ZEN_DIR"
elif [ -d "$BUNDLE_DIR" ] && [ -f "$BUNDLE_DIR/manifest.json" ]; then
    bundle_set_dir "$BUNDLE_DIR"
elif [ -d "$BUNDLE_DIR" ]; then
    bundle_set_dir "$BUNDLE_DIR"
else
    die "No bundle found. Provide archive or directory path."
fi

log "Using bundle: $BUNDLE_DIR"

bundle_import_docker_images
bundle_import_ollama_models
bundle_import_loras "$ZEN_DIR/comfyui/models/loras"
bundle_import_tools
bundle_import_opencode

echo
echo "┌─────────────────────────────────────────────────────────┐"
echo -e "│ ${GREEN}✅ Bundle imported${NC}                                         │"
echo "│                                                         │"
echo "│  Docker images loaded                                   │"
echo "│  Ollama models restored                                 │"
echo "│  LoRAs restored                                         │"
echo "│  screenshot-to-code restored                            │"
echo "│  OpenCode restored                                      │"
echo "│                                                         │"
echo "│  Next: ./scripts/setup.sh --skip-codenest               │"
echo "└─────────────────────────────────────────────────────────┘"
