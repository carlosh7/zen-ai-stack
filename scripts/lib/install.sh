#!/usr/bin/env bash
# install.sh — Tool installation functions for zen-ai-stack
set -euo pipefail

source "${ZEN_SCRIPT_DIR}/lib/common.sh"

install_docker() {
    if command -v docker &>/dev/null; then
        ok "Docker already installed ($(docker --version 2>/dev/null))"
        return 0
    fi
    log "Installing Docker..."
    check_sudo
    curl -fsSL https://get.docker.com | sudo bash
    sudo usermod -aG docker "$USER"
    ok "Docker installed. Re-login required to use docker without sudo."
}

install_git() {
    if command -v git &>/dev/null; then
        ok "Git already installed ($(git --version 2>/dev/null))"
        return 0
    fi
    log "Installing Git..."
    check_sudo
    sudo apt install -y git
    ok "Git installed"
}

install_vscode() {
    if command -v code &>/dev/null; then
        ok "VS Code already installed ($(code --version 2>/dev/null | head -1))"
        return 0
    fi
    log "Installing VS Code..."
    check_sudo
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor -o /etc/apt/keyrings/packages.microsoft.gpg 2>/dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list >/dev/null
    sudo apt update && sudo apt install -y code
    ok "VS Code installed"
}

install_vscode_continue() {
    if code --list-extensions 2>/dev/null | grep -q "continue.continue"; then
        ok "Continue extension already installed"
        return 0
    fi
    log "Installing Continue extension..."
    code --install-extension continue.continue 2>/dev/null || warn "Could not install Continue (VS Code not found)"
    ok "Continue extension installed"
}

install_opencode() {
    if [ -f "$HOME/.opencode/bin/opencode" ]; then
        local version
        version=$("$HOME/.opencode/bin/opencode" --version 2>/dev/null || echo "unknown")
        ok "OpenCode already installed (v${version})"
        log "Updating OpenCode..."
        if curl -fsSL https://opencode.ai/install | bash 2>/dev/null; then
            ok "OpenCode updated"
        else
            warn "OpenCode update failed"
        fi
        return 0
    fi
    log "Installing OpenCode..."
    curl -fsSL https://opencode.ai/install | bash
    ok "OpenCode installed"
}

install_antigravity() {
    if command -v ag &>/dev/null; then
        ok "Antigravity CLI already installed"
        return 0
    fi
    log "Installing Antigravity CLI..."
    if curl -fsSL https://antigravity.google/cli/install.sh | bash 2>/dev/null; then
        ok "Antigravity CLI installed"
    else
        warn "Antigravity installation failed"
    fi
}

install_vtracer() {
    if command -v vtracer &>/dev/null; then
        ok "VTracer already installed"
        return 0
    fi
    log "Installing VTracer..."
    if pip3 install vtracer 2>/dev/null; then
        ok "VTracer installed"
    else
        warn "VTracer not installed (pip3 not found)"
    fi
}

install_inkscape() {
    if command -v inkscape &>/dev/null; then
        ok "Inkscape already installed"
        return 0
    fi
    log "Installing Inkscape..."
    check_sudo
    if sudo apt install -y inkscape 2>/dev/null; then
        ok "Inkscape installed"
    else
        warn "Inkscape not installed"
    fi
}

install_screenshot_to_code() {
    local target_dir="${1:-$HOME/zen-ai-stack/tools/screenshot-to-code}"
    if [ -d "$target_dir" ]; then
        ok "screenshot-to-code already cloned"
        return 0
    fi
    log "Cloning screenshot-to-code..."
    if git clone https://github.com/abi/screenshot-to-code.git "$target_dir" 2>/dev/null; then
        cat > "$target_dir/.env" << 'EOF'
OPENAI_API_KEY=ollama
OPENAI_BASE_URL=http://host.docker.internal:11434/v1
BACKEND_PORT=7001
EOF
        ok "screenshot-to-code cloned and configured"
    else
        warn "Could not clone screenshot-to-code"
        return 1
    fi
}

install_codenest() {
    local target_dir="${1:-$HOME/CodeNest}"
    if [ -d "$target_dir" ]; then
        log "CodeNest found, updating..."
        cd "$target_dir"
        git pull 2>/dev/null || warn "Could not git pull CodeNest"
        docker compose pull 2>/dev/null || warn "Could not pull CodeNest images"
        docker compose up -d 2>/dev/null || warn "Could not start CodeNest"
        ok "CodeNest updated and started"
        return 0
    fi
    if confirm "CodeNest not found. Clone and install?"; then
        log "Cloning CodeNest..."
        git clone https://github.com/carlosh7/CodeNest.git "$target_dir" 2>/dev/null || {
            warn "Could not clone CodeNest"
            return 1
        }
        cd "$target_dir"
        docker compose up -d 2>/dev/null || warn "Could not start CodeNest"
        ok "CodeNest installed and started"
    else
        log "Skipping CodeNest installation"
    fi
}
