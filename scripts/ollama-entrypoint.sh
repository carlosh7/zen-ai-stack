#!/bin/bash
# ollama-entrypoint.sh — Auto-pull models on first start
set -euo pipefail

# Start Ollama in background
/bin/ollama serve &
OLLAMA_PID=$!

# Wait for Ollama to be ready
echo "Waiting for Ollama to start..."
for i in $(seq 1 30); do
    if curl -sf http://localhost:11434/api/tags &>/dev/null; then
        echo "Ollama is ready"
        break
    fi
    sleep 2
done

# Pull models from OLLAMA_MODELS env var (comma-separated)
if [ -n "${OLLAMA_MODELS:-}" ]; then
    echo "Pulling models: ${OLLAMA_MODELS}"
    IFS=',' read -ra model_list <<< "$OLLAMA_MODELS"
    for model in "${model_list[@]}"; do
        model=$(echo "$model" | xargs)
        if [ -n "$model" ]; then
            echo "Pulling ${model}..."
            ollama pull "$model" 2>&1 || echo "Failed to pull ${model}"
        fi
    done
    echo "All models pulled"
fi

# Bring Ollama to foreground
wait "$OLLAMA_PID"
