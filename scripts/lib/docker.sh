#!/usr/bin/env bash
# docker.sh — Docker helper functions for zen-ai-stack
set -euo pipefail

source "${ZEN_SCRIPT_DIR}/lib/common.sh"

compose_up() {
    local compose_file="${1:-$ZEN_DIR/docker-compose.yml}"
    log "Starting Docker stack..."
    cd "$(dirname "$compose_file")"
    docker compose up -d 2>&1 | while IFS= read -r line; do log "$line"; done
    ok "Docker stack started"
}

compose_down() {
    local compose_file="${1:-$ZEN_DIR/docker-compose.yml}"
    log "Stopping Docker stack..."
    cd "$(dirname "$compose_file")"
    docker compose down 2>&1 | while IFS= read -r line; do log "$line"; done
    ok "Docker stack stopped"
}

wait_for_ollama() {
    local timeout=${1:-120}
    local elapsed=0
    log "Waiting for Ollama to be ready..."
    while ! curl -sf http://localhost:11434/api/tags &>/dev/null; do
        sleep 2
        elapsed=$((elapsed + 2))
        if [ "$elapsed" -ge "$timeout" ]; then
            die "Ollama did not start within ${timeout}s"
        fi
        progress_bar $((elapsed / 2)) $((timeout / 2)) "Ollama starting..."
    done
    ok "Ollama is ready"
}

pull_model() {
    local model=$1
    local max_retries=3
    local retry=0
    log "Pulling model: ${model}"
    while [ $retry -lt "$max_retries" ]; do
        if docker exec -i zen-ollama ollama pull "$model" 2>&1; then
            ok "Model pulled: ${model}"
            return 0
        fi
        retry=$((retry + 1))
        warn "Retry $retry/$max_retries for model: ${model}"
        sleep 5
    done
    warn "Failed to pull model: ${model}"
    return 1
}

pull_models() {
    local models=$1
    local IFS
    IFS=','
    read -ra model_list <<< "$models"
    local total=${#model_list[@]}
    local current=0
    log "Pulling ${total} models..."
    for model in "${model_list[@]}"; do
        current=$((current + 1))
        model=$(echo "$model" | xargs)  # trim whitespace
        progress_bar "$current" "$total" "Pulling ${model}..."
        pull_model "$model" &
    done
    wait
    progress_bar "$total" "$total" "All models pulled"
    ok "All models downloaded"
}

pull_loras() {
    local lora_dir="${1:-}"
    local loras=(
        "Logo Design V2 SDXL:https://civitai.com/api/download/models/164034"
        "Flat Design Logo SDXL:https://civitai.com/api/download/models/412235"
        "Minimalist Logo SDXL:https://civitai.com/api/download/models/473661"
        "website-ui-sdxl-lora:https://huggingface.co/anant9/website-ui-sdxl-lora/resolve/main/website-ui-sdxl-lora.safetensors"
    )
    log "Downloading LoRAs..."
    for lora in "${loras[@]}"; do
        local name="${lora%%:*}"
        local url="${lora#*:}"
        local filename="${url##*/}"
        filename="${filename%.safetensors}"
        if [ -n "$lora_dir" ] && [ -f "${lora_dir}/${filename}.safetensors" ]; then
            ok "LoRA already exists: ${name}"
            continue
        fi
        if [ -n "$lora_dir" ]; then
            log "Downloading LoRA: ${name}"
            curl -L -s -o "${lora_dir}/${filename}.safetensors" "$url" &
        fi
    done
    wait
    ok "LoRAs downloaded (if any were missing)"
}

docker_ensure_network() {
    local network="zen-ai-stack"
    if ! docker network ls --format '{{.Name}}' | grep -q "^${network}$"; then
        docker network create "$network" >/dev/null
        ok "Docker network created: ${network}"
    fi
}

check_docker_version() {
    local min_version="24.0"
    local current_version
    current_version=$(docker version --format '{{.Server.Version}}' 2>/dev/null || echo "0")
    if [ "$(printf '%s\n' "$min_version" "$current_version" | sort -V | head -1)" != "$min_version" ]; then
        warn "Docker version $current_version is below recommended $min_version"
    fi
}
