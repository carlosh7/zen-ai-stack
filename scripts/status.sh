#!/usr/bin/env bash
# status.sh — Check zen-ai-stack status
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
export ZEN_DIR ZEN_SCRIPT_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"

zen_status=""

echo "┌─────────────────────────────────────────────────────────┐"
echo "│ zen-ai-stack status                                    │"
echo "├─────────────────────────────────────────────────────────┤"

# Docker services
echo "│ Services:                                              │"
for service in "zen-portainer" "zen-ollama" "zen-open-webui" "zen-comfyui"; do
    if docker ps --format '{{.Names}} {{.Status}}' 2>/dev/null | grep -q "$service"; then
        zen_status=$(docker ps --filter "name=$service" --format '{{.Status}}')
        echo -e "│  ${GREEN}✅${NC} ${service}  ${zen_status}" | head -c 60
        echo
    else
        echo -e "│  ${RED}❌${NC} ${service}  not running"
    fi
done

# Ollama models
echo "│                                                         │"
echo "│ Models:                                                 │"
if curl -sf http://localhost:11434/api/tags 2>/dev/null | python3 -c "
import sys, json
data = json.load(sys.stdin)
for m in data.get('models', []):
    name = m.get('name', m.get('model', '?'))
    size = m.get('size', 0)
    print(f'│  ✅ {name}  ({size/1e9:.1f} GB)')
" 2>/dev/null; then
    :
else
    echo "│  ❌ Ollama not available"
fi

echo "├─────────────────────────────────────────────────────────┤"
echo "│ Ports:                                                  │"
for port in 11434 3000 8188 9443; do
    svc=""
    case "$port" in
        11434) svc="Ollama" ;;
        3000) svc="Open WebUI" ;;
        8188) svc="ComfyUI" ;;
        9443) svc="Portainer" ;;
    esac
    if ss -tlnp "sport = :$port" 2>/dev/null | grep -q "$port"; then
        echo -e "│  ${GREEN}✅${NC} :${port}  ${svc}"
    else
        echo -e "│  ${RED}❌${NC} :${port}  ${svc}  not listening"
    fi
done
echo "└─────────────────────────────────────────────────────────┘"
