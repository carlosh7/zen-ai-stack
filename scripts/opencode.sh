#!/usr/bin/env bash
# opencode.sh — Wrapper that auto-detects Ollama port and configures OpenCode
set -euo pipefail

OPENCODE_BIN="${OPENCODE_BIN:-$HOME/.opencode/bin/opencode}"
OPENCODE_CONFIG="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.json}"

# Auto-detect Ollama port
detect_ollama_port() {
    for port in 11434 11435 11436 11437 11438; do
        if curl -sf "http://localhost:$port/api/tags" &>/dev/null; then
            echo "$port"
            return 0
        fi
    done
    echo "11434"
    return 1
}

OLLAMA_PORT=$(detect_ollama_port)

# Update opencode.json with the detected port
if [ -f "$OPENCODE_CONFIG" ] && command -v python3 &>/dev/null; then
    CURRENT_URL=$(python3 -c "
import json
try:
    with open('$OPENCODE_CONFIG') as f:
        c = json.load(f)
    print(c.get('provider',{}).get('ollama',{}).get('options',{}).get('baseURL',''))
except: print('')
" 2>/dev/null)

    EXPECTED_URL="http://localhost:${OLLAMA_PORT}/v1"
    if [ "$CURRENT_URL" != "$EXPECTED_URL" ]; then
        python3 -c "
import json
with open('$OPENCODE_CONFIG') as f:
    c = json.load(f)
c.setdefault('provider', {})
c['provider'].setdefault('ollama', {})
c['provider']['ollama'].setdefault('options', {})
c['provider']['ollama']['options']['baseURL'] = 'http://localhost:${OLLAMA_PORT}/v1'
with open('$OPENCODE_CONFIG', 'w') as f:
    json.dump(c, f, indent=2)
    f.write('\n')
" 2>/dev/null && echo "  ✅ OpenCode config updated to port ${OLLAMA_PORT}"
    fi
fi

# Run OpenCode
if [ -f "$OPENCODE_BIN" ]; then
    exec "$OPENCODE_BIN" "$@"
else
    echo "❌ OpenCode binary not found at $OPENCODE_BIN"
    echo "   Install with: curl -fsSL https://opencode.ai/install | bash"
    exit 1
fi
