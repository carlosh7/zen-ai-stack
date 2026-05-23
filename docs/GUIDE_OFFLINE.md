# Offline Installation Guide / Guía de Instalación sin Internet

## EN

This guide explains how to install and use zen-ai-stack **without internet access** using a pre-downloaded bundle.

### What is the Bundle?

A bundle is a compressed archive containing everything needed to run zen-ai-stack offline:

- All Docker images (portainer, ollama, open-webui, comfyui)
- All Ollama models (qwen2.5-coder, llama3.2-vision, llama3.2, nomic-embed, deepseek-coder-v2)
- LoRAs for ComfyUI (logo design, web UI)
- screenshot-to-code repository
- OpenCode binary

**Total size:** ~50 GB compressed

### Option A: Someone shares the bundle with you

```bash
# 1. Place the bundle in zen-ai-stack folder
cp /path/to/models-bundle.tar.gz ~/zen-ai-stack/

# 2. Run setup with --offline flag
cd ~/zen-ai-stack
./scripts/setup.sh --offline
```

The script will detect the bundle and install everything from local files instead of downloading from internet.

### Option B: You create the bundle for others

```bash
# 1. First install everything online
cd ~/zen-ai-stack
./scripts/setup.sh --full

# 2. Export the bundle
./scripts/export-bundle.sh

# The bundle is created at: ~/zen-ai-stack/models-bundle.tar.gz (~50 GB)
# Share this file (USB drive, cloud, torrent, etc.)
```

### Option C: Bundle from a custom path

```bash
./scripts/setup.sh --offline /mnt/usb/models-bundle
```

### Requirements for Full Offline Mode

| Component | Included in bundle? | Notes |
|---|---|---|
| Docker Engine | ❌ | Must be installed separately via apt |
| VS Code | ❌ | Must be installed separately (or use --skip-vscode) |
| Inkscape | ❌ | Must be installed separately via apt |
| Git | ❌ | Usually pre-installed, otherwise via apt |
| Docker images | ✅ | Included in bundle |
| Ollama models | ✅ | Included in bundle |
| LoRAs | ✅ | Included in bundle |
| screenshot-to-code | ✅ | Included in bundle |
| OpenCode binary | ✅ | Included in bundle |

### Distribution Methods

| Method | Best for |
|---|---|
| USB Drive (128 GB+) | Physical transfer |
| Local network (LAN) | Office / home sharing |
| Cloud storage (Drive, Mega) | Share with specific users |
| Torrent | Share with many users |

### Troubleshooting

**Bundle not detected:**
```bash
# Ensure manifest.json exists
ls -la models-bundle/manifest.json

# Or extract the archive manually
tar xzf models-bundle.tar.gz
```

**VS Code not installed (offline mode):**
```bash
# Install via apt if available, or use --skip-vscode
./scripts/setup.sh --offline --skip-vscode
```

---

## ES

Esta guía explica cómo instalar y usar zen-ai-stack **sin conexión a internet** usando un bundle precargado.

### ¿Qué es el Bundle?

Un bundle es un archivo comprimido que contiene todo lo necesario para ejecutar zen-ai-stack sin internet:

- Todas las imágenes Docker (portainer, ollama, open-webui, comfyui)
- Todos los modelos Ollama (qwen2.5-coder, llama3.2-vision, llama3.2, nomic-embed, deepseek-coder-v2)
- LoRAs para ComfyUI (diseño de logos, web UI)
- Repositorio de screenshot-to-code
- Binario de OpenCode

**Tamaño total:** ~50 GB comprimido

### Opción A: Alguien te comparte el bundle

```bash
# 1. Coloca el bundle en la carpeta de zen-ai-stack
cp /ruta/models-bundle.tar.gz ~/zen-ai-stack/

# 2. Ejecuta setup con el flag --offline
cd ~/zen-ai-stack
./scripts/setup.sh --offline
```

### Opción B: Creas el bundle para otros

```bash
# 1. Primero instala todo online
cd ~/zen-ai-stack
./scripts/setup.sh --full

# 2. Exporta el bundle
./scripts/export-bundle.sh

# El bundle se crea en: ~/zen-ai-stack/models-bundle.tar.gz (~50 GB)
```

### Opción C: Bundle desde una ruta personalizada

```bash
./scripts/setup.sh --offline /mnt/usb/models-bundle
```

### Requisitos para Modo Totalmente Offline

| Componente | ¿Incluido en bundle? | Notas |
|---|---|---|
| Docker Engine | ❌ | Debe instalarse por separado vía apt |
| VS Code | ❌ | Instalar por separado o usar --skip-vscode |
| Inkscape | ❌ | Instalar por separado vía apt |
| Git | ❌ | Normalmente preinstalado |

### Solución de Problemas

**Bundle no detectado:**
```bash
ls -la models-bundle/manifest.json
tar xzf models-bundle.tar.gz  # Extraer manualmente
```

**VS Code no instalado (modo offline):**
```bash
./scripts/setup.sh --offline --skip-vscode
```
