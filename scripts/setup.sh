#!/usr/bin/env bash
# setup.sh — zen-ai-stack main installer
set -euo pipefail

ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
ZEN_LOG_DIR="${ZEN_LOG_DIR:-$HOME/.zen-ai-stack}"
export ZEN_DIR ZEN_SCRIPT_DIR ZEN_LOG_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"
source "$ZEN_SCRIPT_DIR/lib/detect.sh"
source "$ZEN_SCRIPT_DIR/lib/install.sh"
source "$ZEN_SCRIPT_DIR/lib/docker.sh"

PROFILE="standard"
SKIP_VSCODE=false
SKIP_ANTIGRAVITY=false
SKIP_CODENEST=false
DRY_RUN=false
INTERACTIVE=false

# Services selected for this run
SELECTED_SERVICES=()

parse_args() {
    while [ $# -gt 0 ]; do
        case "$1" in
            --bare) PROFILE="bare" ;;
            --standard) PROFILE="standard" ;;
            --full) PROFILE="full" ;;
            --skip-vscode) SKIP_VSCODE=true ;;
            --skip-antigravity) SKIP_ANTIGRAVITY=true ;;
            --skip-codenest) SKIP_CODENEST=true ;;
            --dry-run) DRY_RUN=true ;;
            --interactive) INTERACTIVE=true ;;
            --version) cat "$ZEN_DIR/VERSION"; exit 0 ;;
            --help)
                echo "zen-ai-stack setup.sh"
                echo "Profiles: --bare (minimal), --standard (default), --full (everything)"
                echo "Flags: --skip-vscode --skip-antigravity --skip-codenest"
                echo "      --dry-run --interactive --version --help"
                exit 0
                ;;
            *) die "Unknown option: $1" ;;
        esac
        shift
    done
}

run_phase() {
    local name=$1
    local func=$2
    if [ "$DRY_RUN" = true ]; then
        log "[DRY-RUN] Would run: ${name}"
        return 0
    fi
    if [ "$INTERACTIVE" = true ]; then
        if ! confirm "Run phase: ${name}?"; then
            log "Skipped: ${name}"
            return 0
        fi
    fi
    log "=== Phase: ${name} ==="
    $func
}

# --- Phases ---

phase_detect() {
    detect_os
    detect_ram
    detect_disk "$ZEN_DIR"
    detect_ports_and_assign
    detect_existing_ollama
    detect_existing_portainer
    detect_tools
    detect_codenest || true
}

phase_git() {
    install_git
}

phase_docker() {
    if [ "$TOOLS_DOCKER" = false ]; then
        install_docker
    fi
    check_docker_version
}

phase_stack() {
    if [ ! -f "$ZEN_DIR/.env" ]; then
        if [ -f "$ZEN_DIR/.env.example" ]; then
            cp "$ZEN_DIR/.env.example" "$ZEN_DIR/.env"
            log "Created .env from .env.example"
            warn "Edit .env to set WEBUI_SECRET_KEY and other values"
        fi
    fi

    # Load env vars into current shell (without overwriting existing)
    set -o allexport
    [ -f "$ZEN_DIR/.env" ] && source "$ZEN_DIR/.env"
    set +o allexport

    # Override ports with detected values
    export HOST_PORT_PORTAINER=${ZEN_PORTAINER_PORT:-9443}
    export HOST_PORT_OLLAMA=${ZEN_OLLAMA_PORT:-11434}
    export HOST_PORT_OPENWEBUI=${ZEN_OPENWEBUI_PORT:-3000}
    export HOST_PORT_COMFYUI=${ZEN_COMFYUI_PORT:-8188}

    # Build service list based on profile and host detection
    SELECTED_SERVICES=()

    if [ "$PORTAINER_ON_HOST" = false ]; then
        SELECTED_SERVICES+=(portainer)
    else
        log "Portainer already running — skipping container"
    fi

    if [ "$OLLAMA_ON_HOST" = false ]; then
        SELECTED_SERVICES+=(ollama)
    else
        log "Ollama already running on host — skipping container"
    fi

    if [ "$PROFILE" != "bare" ]; then
        if [ "${ZEN_OPENWEBUI_PORT:-3000}" != "3000" ]; then
            log "Open WebUI port adjusted to ${ZEN_OPENWEBUI_PORT}"
        fi
        SELECTED_SERVICES+=(open-webui)
    fi

    if [ "$PROFILE" = "full" ]; then
        SELECTED_SERVICES+=(comfyui)
    fi

    if [ ${#SELECTED_SERVICES[@]} -gt 0 ]; then
        compose_up "$ZEN_DIR/docker-compose.yml" "${SELECTED_SERVICES[@]}"
    else
        log "No services to start"
    fi
}

phase_models() {
    if [ "$OLLAMA_ON_HOST" = false ]; then
        wait_for_ollama 180
    fi

    local models="qwen2.5-coder:7b"
    if [ "$PROFILE" = "standard" ] || [ "$PROFILE" = "full" ]; then
        models="qwen2.5-coder:7b,qwen2.5-vl:7b,llama3.2:3b,nomic-embed-text"
    fi
    if [ "$PROFILE" = "full" ]; then
        models="${models},deepseek-coder-v2-lite:16b"
    fi
    pull_models "$models"
}

phase_opencode() {
    install_opencode
    merge_opencode_config
}

merge_opencode_config() {
    local config_file="${OPENCODE_CONFIG:-$HOME/.config/opencode/opencode.json}"
    local backup_file="${config_file}.bak"

    if [ -f "$config_file" ]; then
        cp "$config_file" "$backup_file"
        ok "Backup created: ${backup_file}"
    fi

    mkdir -p "$(dirname "$config_file")"
    if [ ! -f "$config_file" ]; then
        cat > "$config_file" << 'EOF'
{
  "$schema": "https://opencode.ai/config.json",
  "model": "qwen2.5-coder:7b",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (local)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:7b": {},
        "qwen2.5-vl:7b": {},
        "llama3.2:3b": {},
        "nomic-embed-text": {}
      }
    }
  }
}
EOF
        ok "OpenCode config created"
    else
        if ! grep -q '"ollama"' "$config_file" 2>/dev/null; then
            log "Adding Ollama provider to existing OpenCode config..."
            if command -v python3 &>/dev/null; then
                python3 -c "
import json
with open('$config_file', 'r') as f:
    config = json.load(f)
config['provider'] = {
    'ollama': {
        'npm': '@ai-sdk/openai-compatible',
        'name': 'Ollama (local)',
        'options': {'baseURL': 'http://localhost:11434/v1'},
        'models': {
            'qwen2.5-coder:7b': {},
            'qwen2.5-vl:7b': {},
            'llama3.2:3b': {},
            'nomic-embed-text': {},
            'deepseek-coder-v2-lite:16b': {}
        }
    }
}
with open('$config_file', 'w') as f:
    json.dump(config, f, indent=2)
    f.write('\n')
"
                ok "OpenCode config merged with local providers"
            else
                warn "python3 not found for JSON merge. Add provider manually."
            fi
        else
            ok "OpenCode config already has Ollama provider"
        fi
    fi
}

phase_vscode() {
    if [ "$SKIP_VSCODE" = true ]; then
        log "Skipping VS Code (--skip-vscode)"
        return 0
    fi
    install_vscode
    install_vscode_continue
}

phase_antigravity() {
    if [ "$SKIP_ANTIGRAVITY" = true ]; then
        log "Skipping Antigravity (--skip-antigravity)"
        return 0
    fi
    install_antigravity
}

phase_design_tools() {
    if [ "$PROFILE" != "full" ]; then
        return 0
    fi
    install_vtracer
    install_inkscape
    pull_loras "$ZEN_DIR/comfyui/models/loras"
}

phase_screenshot_to_code() {
    if [ "$PROFILE" != "full" ]; then
        return 0
    fi
    install_screenshot_to_code "$ZEN_DIR/tools/screenshot-to-code"
}

phase_codenest() {
    if [ "$SKIP_CODENEST" = true ]; then
        log "Skipping CodeNest (--skip-codenest)"
        return 0
    fi
    install_codenest "$HOME/CodeNest"
}

phase_verify() {
    log "=== Verifying installation ==="
    local total=0
    local ok_count=0

    verify_service() {
        local name=$1
        local container=$2
        local url=$3
        local expected=${4:-true}
        total=$((total + 1))
        if [ "$expected" = false ]; then
            return
        fi
        if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "$container"; then
            ok "${name} running (container)"
            ok_count=$((ok_count + 1))
        elif [ -n "$url" ] && curl -sf "$url" &>/dev/null; then
            ok "${name} running (host)"
            ok_count=$((ok_count + 1))
        else
            warn "${name} not detected"
        fi
    }

    verify_service "Portainer" "zen-portainer" "https://localhost:${ZEN_PORTAINER_PORT:-9443}" "$PORTAINER_ON_HOST"
    verify_service "Portainer" "portainer" "https://localhost:9443" "$PORTAINER_ON_HOST"

    if [ "$OLLAMA_ON_HOST" = true ]; then
        verify_service "Ollama" "" "http://localhost:11434/api/tags" true
    else
        verify_service "Ollama" "zen-ollama" "http://localhost:${ZEN_OLLAMA_PORT:-11434}/api/tags" true
    fi

    if [ "$PROFILE" != "bare" ]; then
        verify_service "Open WebUI" "zen-open-webui" "http://localhost:${ZEN_OPENWEBUI_PORT:-3000}" true
    fi
    if [ "$PROFILE" = "full" ]; then
        verify_service "ComfyUI" "zen-comfyui" "http://localhost:${ZEN_COMFYUI_PORT:-8188}" true
    fi

    if [ "$ok_count" -eq "$total" ]; then
        ok "All ${total} services verified"
    else
        warn "${ok_count}/${total} services verified"
    fi
}

show_summary() {
    local ollama_port="${ZEN_OLLAMA_PORT:-11434}"
    local webui_port="${ZEN_OPENWEBUI_PORT:-3000}"
    local comfy_port="${ZEN_COMFYUI_PORT:-8188}"
    local portainer_port="${ZEN_PORTAINER_PORT:-9443}"

    echo
    echo "┌─────────────────────────────────────────────────────────┐"
    echo -e "│ ${GREEN}✅ zen-ai-stack installed${NC}                                 │"
    echo "│ Profile: ${PROFILE}                                       │"
    echo "│                                                         │"
    echo "│  Services:                                              │"
    if [ "$PORTAINER_ON_HOST" = true ]; then
        echo "│  Portainer   → https://localhost:9443 (existing host)   │"
    else
        echo "│  Portainer   → https://localhost:${portainer_port}                     │"
    fi
    if [ "$OLLAMA_ON_HOST" = true ]; then
        echo "│  Ollama      → http://localhost:11434 (existing host)   │"
    else
        echo "│  Ollama      → http://localhost:${ollama_port}                       │"
    fi
    if [ "$PROFILE" != "bare" ]; then
        echo "│  Open WebUI  → http://localhost:${webui_port}                         │"
    fi
    if [ "$PROFILE" = "full" ]; then
        echo "│  ComfyUI     → http://localhost:${comfy_port}                         │"
    fi
    echo "│                                                         │"
    echo "│  Commands:                                              │"
    echo "│  make status    — Check everything                      │"
    echo "│  make logs      — View live logs                        │"
    echo "│  make update    — Pull latest images + models           │"
    echo "│  make uninstall — Remove everything                     │"
    echo "│                                                         │"
    echo "│  ⚡ Log: ${LOG_FILE}                      │"
    echo "└─────────────────────────────────────────────────────────┘"
}

# --- Main ---
main() {
    init_log
    log "zen-ai-stack v$(cat "$ZEN_DIR/VERSION") — Profile: ${PROFILE}"
    log "Log file: ${LOG_FILE}"

    parse_args "$@"

    run_phase "Detect system" phase_detect
    run_phase "Install Git" phase_git
    run_phase "Docker" phase_docker
    run_phase "Deploy Docker stack" phase_stack
    run_phase "Download models" phase_models
    run_phase "Install and configure OpenCode" phase_opencode
    run_phase "Install VS Code" phase_vscode
    run_phase "Install Antigravity" phase_antigravity
    if [ "$PROFILE" = "full" ]; then
        run_phase "Design tools" phase_design_tools
        run_phase "Screenshot-to-code" phase_screenshot_to_code
    fi
    run_phase "CodeNest" phase_codenest
    run_phase "Verify" phase_verify
    show_summary
}

main "$@"
