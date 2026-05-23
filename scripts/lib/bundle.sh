#!/usr/bin/env bash
# bundle.sh — Shared functions for offline bundle operations
set -euo pipefail

source "${ZEN_SCRIPT_DIR}/lib/common.sh"

BUNDLE_DIR="${BUNDLE_DIR:-}"
BUNDLE_MANIFEST=""

bundle_set_dir() {
    BUNDLE_DIR="${1:-$ZEN_DIR/models-bundle}"
    BUNDLE_MANIFEST="$BUNDLE_DIR/manifest.json"
    mkdir -p "$BUNDLE_DIR/docker-images" "$BUNDLE_DIR/ollama-models" "$BUNDLE_DIR/loras" "$BUNDLE_DIR/tools" "$BUNDLE_DIR/opencode"
    log "Bundle directory: $BUNDLE_DIR"
}

bundle_detect() {
    local search_paths=("$1" "$ZEN_DIR/models-bundle" "$ZEN_DIR/../models-bundle" "$HOME/models-bundle")
    for path in "${search_paths[@]}"; do
        if [ -f "$path/manifest.json" ]; then
            BUNDLE_DIR="$path"
            BUNDLE_MANIFEST="$BUNDLE_DIR/manifest.json"
            log "Bundle found at: $BUNDLE_DIR"
            return 0
        fi
    done
    return 1
}

bundle_export_docker_images() {
    local images=(
        "portainer/portainer-ce:lts:portainer.tar"
        "ollama/ollama:latest:ollama.tar"
        "ghcr.io/open-webui/open-webui:latest:open-webui.tar"
        "yanwk/comfyui-boot:cpu:comfyui.tar"
    )
    log "Exporting Docker images..."
    for entry in "${images[@]}"; do
        local image="${entry%%:*}"
        local rest="${entry#*:}"
        local tag="${rest%%:*}"
        local filename="${rest##*:}"
        if docker images --format '{{.Repository}}:{{.Tag}}' 2>/dev/null | grep -q "${image}:${tag}"; then
            log "Saving ${image}:${tag}..."
            docker save "${image}:${tag}" -o "$BUNDLE_DIR/docker-images/$filename" 2>/dev/null &
        else
            warn "Image ${image}:${tag} not found locally"
        fi
    done
    wait
    ok "Docker images exported"
}

bundle_export_ollama_models() {
    log "Exporting Ollama models..."
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q zen-ollama; then
        docker run --rm -v zen-ai-stack_ollama_data:/root/.ollama -v "$BUNDLE_DIR/ollama-models:/backup" \
            alpine tar czf /backup/ollama-models.tar.gz -C /root/.ollama . 2>/dev/null
        ok "Ollama models exported"
    else
        warn "zen-ollama not running — cannot export models"
        return 1
    fi
}

bundle_export_loras() {
    local lora_dir="${1:-$ZEN_DIR/comfyui/models/loras}"
    if [ -d "$lora_dir" ] && [ "$(ls -A "$lora_dir" 2>/dev/null)" ]; then
        log "Exporting LoRAs..."
        cp "$lora_dir"/*.safetensors "$BUNDLE_DIR/loras/" 2>/dev/null
        ok "LoRAs exported"
    else
        log "No LoRAs found to export"
    fi
}

bundle_export_screenshot_to_code() {
    local src="${1:-$ZEN_DIR/tools/screenshot-to-code}"
    if [ -d "$src" ]; then
        log "Exporting screenshot-to-code..."
        cp -r "$src" "$BUNDLE_DIR/tools/" 2>/dev/null
        ok "screenshot-to-code exported"
    fi
}

bundle_export_opencode() {
    log "Exporting OpenCode binary..."
    if [ -f "$HOME/.opencode/bin/opencode" ]; then
        cp "$HOME/.opencode/bin/opencode" "$BUNDLE_DIR/opencode/"
        ok "OpenCode binary exported"
    else
        log "Downloading OpenCode binary for bundle..."
        curl -fsSL https://opencode.ai/install -o /tmp/opencode-install.sh 2>/dev/null
        bash /tmp/opencode-install.sh 2>/dev/null
        if [ -f "$HOME/.opencode/bin/opencode" ]; then
            cp "$HOME/.opencode/bin/opencode" "$BUNDLE_DIR/opencode/"
            ok "OpenCode downloaded and exported"
        else
            warn "Could not download OpenCode for bundle"
        fi
    fi
}

bundle_write_manifest() {
    local total_size
    total_size=$(du -sh "$BUNDLE_DIR" 2>/dev/null | awk '{print $1}')
    cat > "$BUNDLE_MANIFEST" << EOF
{
  "created": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "version": "$(cat "$ZEN_DIR/VERSION" 2>/dev/null || echo "unknown")",
  "total_size": "$total_size",
  "contents": {
    "docker_images": $(ls "$BUNDLE_DIR/docker-images/" 2>/dev/null | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin.readlines() if l.strip()]))" 2>/dev/null || echo "[]"),
    "ollama_models": $( [ -f "$BUNDLE_DIR/ollama-models/ollama-models.tar.gz" ] && echo '"ollama-models.tar.gz"' || echo 'null' ),
    "loras": $(ls "$BUNDLE_DIR/loras/" 2>/dev/null | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin.readlines() if l.strip()]))" 2>/dev/null || echo "[]"),
    "tools": $(ls "$BUNDLE_DIR/tools/" 2>/dev/null | python3 -c "import sys,json; print(json.dumps([l.strip() for l in sys.stdin.readlines() if l.strip()]))" 2>/dev/null || echo "[]"),
    "opencode": $( [ -f "$BUNDLE_DIR/opencode/opencode" ] && echo '"opencode"' || echo 'null' )
  }
}
EOF
    ok "Manifest written: $BUNDLE_MANIFEST"
}

bundle_import_docker_images() {
    log "Loading Docker images from bundle..."
    local count=0
    for img in "$BUNDLE_DIR/docker-images/"*.tar; do
        if [ -f "$img" ]; then
            docker load -i "$img" 2>/dev/null && ok "Loaded: $(basename "$img")" && count=$((count+1)) || warn "Failed: $(basename "$img")"
        fi
    done
    if [ "$count" -gt 0 ]; then
        ok "${count} Docker images loaded"
    else
        warn "No Docker images found in bundle"
    fi
}

bundle_import_ollama_models() {
    if [ -f "$BUNDLE_DIR/ollama-models/ollama-models.tar.gz" ]; then
        log "Restoring Ollama models from bundle..."
        docker run --rm -v zen-ai-stack_ollama_data:/root/.ollama -v "$BUNDLE_DIR/ollama-models:/backup" \
            alpine tar xzf /backup/ollama-models.tar.gz -C /root/.ollama 2>/dev/null
        ok "Ollama models restored"
    else
        warn "No Ollama model bundle found"
    fi
}

bundle_import_loras() {
    local target="${1:-$ZEN_DIR/comfyui/models/loras}"
    if [ "$(ls -A "$BUNDLE_DIR/loras/" 2>/dev/null)" ]; then
        log "Restoring LoRAs..."
        mkdir -p "$target"
        cp "$BUNDLE_DIR/loras/"*.safetensors "$target/" 2>/dev/null
        ok "LoRAs restored"
    fi
}

bundle_import_tools() {
    if [ -d "$BUNDLE_DIR/tools/screenshot-to-code" ]; then
        log "Restoring screenshot-to-code..."
        mkdir -p "$ZEN_DIR/tools"
        cp -r "$BUNDLE_DIR/tools/screenshot-to-code" "$ZEN_DIR/tools/" 2>/dev/null
        ok "screenshot-to-code restored"
    fi
}

bundle_import_opencode() {
    if [ -f "$BUNDLE_DIR/opencode/opencode" ]; then
        log "Restoring OpenCode binary..."
        mkdir -p "$HOME/.opencode/bin"
        cp "$BUNDLE_DIR/opencode/opencode" "$HOME/.opencode/bin/" 2>/dev/null
        chmod +x "$HOME/.opencode/bin/opencode"
        ok "OpenCode binary restored"
    fi
}

bundle_create_archive() {
    local archive="${1:-$ZEN_DIR/models-bundle.tar.gz}"
    local bundle_dir="${BUNDLE_DIR:-$ZEN_DIR/models-bundle}"
    log "Creating archive: $archive..."
    cd "$(dirname "$bundle_dir")"
    tar czf "$archive" "$(basename "$bundle_dir")" 2>/dev/null
    ok "Archive created: $archive ($(du -h "$archive" | awk '{print $1}'))"
}

bundle_extract_archive() {
    local archive="${1:-$ZEN_DIR/models-bundle.tar.gz}"
    local target="${2:-$ZEN_DIR}"
    if [ -f "$archive" ]; then
        log "Extracting archive: $archive..."
        tar xzf "$archive" -C "$(dirname "$target")" 2>/dev/null
        ok "Archive extracted"
        BUNDLE_DIR="${target}/models-bundle"
        BUNDLE_MANIFEST="$BUNDLE_DIR/manifest.json"
    else
        die "Archive not found: $archive"
    fi
}
