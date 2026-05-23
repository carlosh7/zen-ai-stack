#!/usr/bin/env bash
# setup.sh — zen-ai-stack main installer
set -euo pipefail

# --- Configuration ---
ZEN_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ZEN_SCRIPT_DIR="$ZEN_DIR/scripts"
ZEN_LOG_DIR="${ZEN_LOG_DIR:-$HOME/.zen-ai-stack}"
export ZEN_DIR ZEN_SCRIPT_DIR ZEN_LOG_DIR

source "$ZEN_SCRIPT_DIR/lib/common.sh"
source "$ZEN_SCRIPT_DIR/lib/detect.sh"
source "$ZEN_SCRIPT_DIR/lib/install.sh"
source "$ZEN_SCRIPT_DIR/lib/docker.sh"

# --- Defaults ---
PROFILE="standard"
SKIP_VSCODE=false
SKIP_ANTIGRAVITY=false
SKIP_CODENEST=false
DRY_RUN=false
INTERACTIVE=false

# --- Parse arguments ---
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

# --- Phase runner ---
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
    detect_ports
    detect_tools
    detect_codenest || true
}

phase_git() {
    install_git
}

phase_docker() {
    install_docker
    check_docker_version
    docker_ensure_network
}

phase_stack() {
    local compose_profile=""
    if [ ! -f "$ZEN_DIR/.env" ]; then
        if [ -f "$ZEN_DIR/.env.example" ]; then
            cp "$ZEN_DIR/.env.example" "$ZEN_DIR/.env"
            log "Created .env from .env.example"
            warn "Edit .env to set WEBUI_SECRET_KEY and other values"
        fi
    fi
    case "$PROFILE" in
        bare) compose_profile="" ;;
        standard) compose_profile="standard" ;;
        full) compose_profile="full" ;;
    esac
    compose_up "$ZEN_DIR/docker-compose.yml" "$compose_profile"
}

phase_models() {
    wait_for_ollama 180

    # Determine models based on profile
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

    # Backup existing config
    if [ -f "$config_file" ]; then
        cp "$config_file" "$backup_file"
        ok "Backup created: ${backup_file}"
    fi

    # Create or merge
    mkdir -p "$(dirname "$config_file")"
    if [ ! -f "$config_file" ]; then
        # Create new config
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
    local errors=0
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-portainer || { warn "Portainer not running"; errors=$((errors+1)); }
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-ollama || { warn "Ollama not running"; errors=$((errors+1)); }
    docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-open-webui || { warn "Open WebUI not running"; errors=$((errors+1)); }
    if [ "$PROFILE" = "full" ]; then
        docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-comfyui || { warn "ComfyUI not running"; errors=$((errors+1)); }
    fi
    curl -sf http://localhost:11434/api/tags &>/dev/null || { warn "Ollama API not responding"; errors=$((errors+1)); }
    if [ "$errors" -eq 0 ]; then
        ok "All services verified"
    else
        warn "${errors} service(s) not verified. Check docker compose logs."
    fi
}

show_summary() {
    echo
    echo "┌─────────────────────────────────────────────────────────┐"
    echo -e "│ ${GREEN}✅ zen-ai-stack installed${NC}                                 │"
    echo "│ Profile: ${PROFILE}                                       │"
    echo "│                                                         │"
    echo "│  Services:                                              │"
    echo "│  Portainer   → https://localhost:${HOST_PORT_PORTAINER:-9443}              │"
    echo "│  Ollama      → http://localhost:${HOST_PORT_OLLAMA:-11434}                 │"
    echo "│  Open WebUI  → http://localhost:${HOST_PORT_OPENWEBUI:-3000}                │"
    echo "│  ComfyUI     → http://localhost:${HOST_PORT_COMFYUI:-8188}                 │"
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
    run_phase "Install Docker" phase_docker
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
