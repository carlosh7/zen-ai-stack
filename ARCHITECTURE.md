# Architecture — zen-ai-stack

## Overview

zen-ai-stack unifies 4 layers for local AI development:

1. **Orchestration** (Portainer) — Visual Docker container management
2. **Processing** (Ollama) — Local LLM engine (5 models)
3. **Image** (ComfyUI) — Image generation via SDXL + LoRAs
4. **Control** (Open WebUI) — Unified chat + image interface

## Network Diagram

```
HOST (Linux / WSL2)
│
├── Docker Network: zen-ai-stack
│   ├── portainer  (:9443) → Container management
│   ├── ollama     (:11434) → LLM engine
│   ├── open-webui (:3000)  → Unified UI (connects to ollama + comfyui)
│   └── comfyui    (:8188)  → Image generation
│
├── Editors (Host)
│   ├── OpenCode        → localhost:11434/v1
│   ├── VS Code+Continue → localhost:11434/v1
│   └── CodeNest        → host.docker.internal:11434
│
└── Tools (Host)
    ├── VTracer   → PNG → SVG
    └── Inkscape  → Vector editing
```

## Services

| Service | Image | Port | Volumes | Key Env |
|---|---|---|---|---|
| portainer | portainer/portainer-ce:lts | 9443 | portainer_data | — |
| ollama | ollama/ollama | 11434 | ollama_data | OLLAMA_MODELS |
| open-webui | ghcr.io/open-webui/open-webui | 3000 | open-webui_data | ENABLE_IMAGE_GENERATION, COMFYUI_BASE_URL |
| comfyui | yanwk/comfyui-boot:latest | 8188 | models, loras, output, custom_nodes, user | CLI_ARGS=--force-fp16 --lowvram-mode |

## Data Flow

### Text Chat
```
User → Open WebUI (:3000) → Ollama (:11434) → Model → Response
User → OpenCode / VS Code → localhost:11434/v1 → Ollama → Response
```

### Image Generation
```
User → Open WebUI (/image prompt) → ComfyUI (:8188) → SDXL + LoRA → Image
```

### Screenshot → Code (full profile)
```
Screenshot → screenshot-to-code (:5173) → Ollama vision model → HTML/CSS code
```

## Model Loading Strategy

Models are loaded on demand by Ollama. Only active models consume RAM:
- A model stays loaded for ~5 minutes after last use (configurable)
- You can run multiple models sequentially without conflict
- Total 14 GB required only if all 5 models are loaded simultaneously
- With 32 GB RAM, you have ~18 GB free for other tasks

## Persistence

All data persists in Docker named volumes:
- `ollama_data` — Models and Ollama configuration
- `open-webui_data` — Chats, users, settings
- `comfyui_*` — Models, LoRAs, generated images, custom nodes
- `portainer_data` — Portainer state

## Security Notes

- Portainer requires initial admin password setup on first access
- Open WebUI requires first user registration (becomes admin)
- All services are accessible only on localhost by default
- No external network exposure without explicit firewall rules
