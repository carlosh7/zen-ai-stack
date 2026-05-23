# Profiles / Perfiles

## EN

zen-ai-stack offers three installation profiles to match your hardware and needs.

### bare

**Command:** `./scripts/setup.sh --bare`
**RAM:** ~5 GB
**Time:** ~10 min
**Includes:**
- Docker + Portainer
- Ollama + 1 model (qwen2.5-coder:7b)
- Git

**Best for:** Minimal setups, low-RAM devices, or when you only need code assistance.

### standard (default)

**Command:** `./scripts/setup.sh` or `./scripts/setup.sh --standard`
**RAM:** ~12 GB
**Time:** ~45 min
**Includes:**
- Everything in bare
- 4 Ollama models (qwen2.5-coder, qwen2.5-vl, llama3.2, nomic-embed)
- Open WebUI (chat interface)
- OpenCode + VS Code + Continue
- Antigravity CLI

**Best for:** Daily development with AI assistance, writing, and RAG.

### full

**Command:** `./scripts/setup.sh --full`
**RAM:** ~18 GB
**Time:** ~60 min
**Includes:**
- Everything in standard
- 5th model (deepseek-coder-v2-lite:16b)
- ComfyUI + 4 LoRAs
- screenshot-to-code
- VTracer + Inkscape
- CodeNest (auto-install)

**Best for:** Complete AI studio — coding, design, image generation, and project management.

## ES

zen-ai-stack ofrece tres perfiles de instalación para adaptarse a tu hardware y necesidades.

### bare

**Comando:** `./scripts/setup.sh --bare`
**RAM:** ~5 GB
**Tiempo:** ~10 min
**Incluye:**
- Docker + Portainer
- Ollama + 1 modelo (qwen2.5-coder:7b)
- Git

**Ideal para:** Configuraciones mínimas, dispositivos con poca RAM, o cuando solo necesitas asistencia de código.

### standard (predeterminado)

**Comando:** `./scripts/setup.sh` o `./scripts/setup.sh --standard`
**RAM:** ~12 GB
**Tiempo:** ~45 min
**Incluye:**
- Todo lo de bare
- 4 modelos Ollama (qwen2.5-coder, qwen2.5-vl, llama3.2, nomic-embed)
- Open WebUI (interfaz de chat)
- OpenCode + VS Code + Continue
- Antigravity CLI

**Ideal para:** Desarrollo diario con asistencia IA, escritura y RAG.

### full

**Comando:** `./scripts/setup.sh --full`
**RAM:** ~18 GB
**Tiempo:** ~60 min
**Incluye:**
- Todo lo de standard
- 5º modelo (deepseek-coder-v2-lite:16b)
- ComfyUI + 4 LoRAs
- screenshot-to-code
- VTracer + Inkscape
- CodeNest (instalación automática)

**Ideal para:** Estudio de IA completo — programación, diseño, generación de imágenes y gestión de proyectos.
