#!/usr/bin/env bash
# detect.sh — OS, hardware, and tool detection for zen-ai-stack
set -euo pipefail

source "${ZEN_SCRIPT_DIR}/lib/common.sh"

# Global state variables set by detect functions
RAM_GB=0
DISK_GB=0
OLLAMA_ON_HOST=false
PORTAINER_ON_HOST=false
declare -A SERVICE_PORTS

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

detect_ports_and_assign() {
    local services_def=(
        "portainer:9443:ZEN_PORTAINER_PORT"
        "ollama:11434:ZEN_OLLAMA_PORT"
        "open-webui:3000:ZEN_OPENWEBUI_PORT"
        "comfyui:8188:ZEN_COMFYUI_PORT"
    )
    log "Checking port availability..."
    for entry in "${services_def[@]}"; do
        local svc="${entry%%:*}"
        local rest="${entry#*:}"
        local default_port="${rest%%:*}"
        local env_var="${rest##*:}"
        local assigned=$default_port
        while ss -tlnp "sport = :$assigned" 2>/dev/null | grep -q "$assigned"; do
            assigned=$((assigned + 1))
        done
        SERVICE_PORTS["$svc"]=$assigned
        export "$env_var=$assigned"
        if [ "$assigned" != "$default_port" ]; then
            warn "${svc}: port ${default_port} in use → using ${assigned}"
        else
            ok "${svc}: using port ${assigned}"
        fi
    done
}

detect_existing_ollama() {
    OLLAMA_ON_HOST=false
    if command -v ollama &>/dev/null && curl -sf http://localhost:11434/api/tags &>/dev/null; then
        OLLAMA_ON_HOST=true
        warn "Ollama binary + API found on host. Container will be skipped."
    elif curl -sf http://localhost:11434/api/tags &>/dev/null && ! docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-ollama; then
        OLLAMA_ON_HOST=true
        warn "Ollama API responding on host (not our container). Skipping container."
    else
        OLLAMA_ON_HOST=false
    fi
}

detect_existing_portainer() {
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q -E '^portainer$|^zen-portainer$'; then
        PORTAINER_ON_HOST=true
        warn "Portainer already running. Container will be skipped."
    else
        PORTAINER_ON_HOST=false
    fi
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

detect_network() {
    if ping -c 1 -W 2 8.8.8.8 &>/dev/null; then
        return 0
    fi
    warn "No internet connection detected. Model downloads will be skipped."
    return 1
}
