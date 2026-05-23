#!/usr/bin/env bash
# detect.sh — OS, hardware, and tool detection for zen-ai-stack
set -euo pipefail

# shellcheck source=scripts/lib/common.sh
source "${ZEN_SCRIPT_DIR}/lib/common.sh"

detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS_ID=$ID
        OS_VERSION=$VERSION_ID
        OS_NAME=$NAME
    else
        OS_ID=$(uname -s)
        OS_VERSION=$(uname -r)
        OS_NAME=$OS_ID
    fi
    log "OS: ${OS_NAME} ${OS_VERSION}"
}

detect_ram() {
    local total_kb total_gb
    if [ -f /proc/meminfo ]; then
        total_kb=$(grep MemTotal /proc/meminfo | awk '{print $2}')
        total_gb=$(( total_kb / 1024 / 1024 ))
    else
        total_gb=0
    fi
    RAM_GB=$total_gb
    log "RAM: ${RAM_GB} GB"
    if [ "$RAM_GB" -lt 16 ]; then
        warn "Less than 16 GB RAM detected. Performance may be limited."
    fi
}

detect_disk() {
    local dir=${1:-$ZEN_DIR}
    local available_gb
    available_gb=$(df -BG "$dir" | awk 'NR==2 {print $4}' | sed 's/G//')
    DISK_GB=$available_gb
    log "Disk available: ${DISK_GB} GB"
    if [ "$available_gb" -lt 40 ]; then
        warn "Less than 40 GB free. Models may not fit."
    fi
}

detect_ports() {
    local ports=(11434 3000 8188 9443 5173 7001)
    for port in "${ports[@]}"; do
        if ss -tlnp "sport = :$port" 2>/dev/null | grep -q "$port"; then
            warn "Port $port is already in use"
        fi
    done
}

detect_tools() {
    TOOLS_DOCKER=false
    TOOLS_GIT=false
    TOOLS_CODE=false
    TOOLS_OPENCODE=false

    command -v docker &>/dev/null && TOOLS_DOCKER=true
    command -v git &>/dev/null && TOOLS_GIT=true
    command -v code &>/dev/null && TOOLS_CODE=true
    [ -f "$HOME/.opencode/bin/opencode" ] && TOOLS_OPENCODE=true

    log "Tools detected: docker=$TOOLS_DOCKER git=$TOOLS_GIT vscode=$TOOLS_CODE opencode=$TOOLS_OPENCODE"
}

detect_codenest() {
    # Search common locations for CodeNest
    local locations=("$HOME/CodeNest" "$HOME/codenest" "$ZEN_DIR/../CodeNest")
    CODENEST_DIR=""
    for loc in "${locations[@]}"; do
        if [ -f "$loc/docker-compose.yml" ]; then
            CODENEST_DIR=$loc
            log "CodeNest found at: $CODENEST_DIR"
            return 0
        fi
    done
    log "CodeNest not found"
    return 1
}

detect_ollama_running() {
    if curl -sf http://localhost:11434/api/tags &>/dev/null; then
        return 0
    fi
    return 1
}

detect_network() {
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        return 0
    fi
    warn "No internet connection detected. Model downloads will be skipped."
    return 1
}
