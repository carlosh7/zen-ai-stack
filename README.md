# 🧠 zen-ai-stack

> Your local AI studio for coding, designing, and creating.
> Runs 100% offline on your laptop.

> Tu estudio de IA local para programar, diseñar y crear.
> Corre 100% offline en tu portátil.

---

## ✨ Capabilities / Capacidades

| What you can do / Qué puedes hacer | Tools / Herramientas |
|---|---|
| Code with AI / Programar con IA | OpenCode + Qwen2.5-Coder 7B |
| Chat with documents / Chatear con documentos | Open WebUI + RAG |
| Generate logos / Generar logos | ComfyUI + SDXL + LoRAs + VTracer |
| Design web pages / Diseñar páginas web | ComfyUI + screenshot-to-code |
| Design mobile apps / Diseñar apps móviles | ComfyUI + Qwen2.5-Coder (Flutter/Kotlin) |
| Write documentation / Escribir documentación | Qwen2.5 7B |
| Manage projects / Gestionar proyectos | CodeNest |

---

## 📦 Stack

```
┌──────────────────────────────────────────────────────────────┐
│                 HOST (Linux / WSL2)                          │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Docker Network: zen-ai-stack             │   │
│  │  ┌──────────┐  ┌────────┐  ┌──────────┐  ┌───────┐  │   │
│  │  │ portainer│  │ ollama │  │open-webui│  │comfyui│  │   │
│  │  │  :9443   │  │ :11434 │  │  :3000   │  │ :8188  │  │   │
│  │  └──────────┘  └────────┘  └──────────┘  └───────┘  │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                              │
│  Editors (Host):  OpenCode  │  VS Code+Continue  │  CodeNest│
│                    ──→ localhost:11434/v1 ──→ Ollama         │
└──────────────────────────────────────────────────────────────┘
```

---

## 🖥️ Requirements / Requisitos

| Resource | Minimum | Recommended |
|---|---|---|
| RAM | 16 GB | 32 GB |
| Disk | 40 GB free | 60 GB+ SSD |
| OS | Linux (Ubuntu 22.04+) | Linux or WSL2 |
| Docker | 24+ | Latest stable |
| Internet | Installation only | — |

---

## ⚡ Quick Install / Instalación rápida

```bash
git clone https://github.com/carlosh7/zen-ai-stack.git
cd zen-ai-stack
cp .env.example .env
./scripts/setup.sh
```

### One-liner (coming soon)
```bash
curl -fsSL https://raw.githubusercontent.com/carlosh7/zen-ai-stack/main/scripts/setup.sh | bash
```

---

## 🎯 Profiles / Perfiles

| Profile | Command | RAM | Time | Includes |
|---|---|---|---|---|
| **bare** | `--bare` | ~5 GB | 10 min | Docker + Ollama + 1 model |
| **standard** | *(default)* | ~12 GB | 45 min | + WebUI + OpenCode + VS Code |
| **full** | `--full` | ~18 GB | 60 min | + ComfyUI + CodeNest + screenshot-to-code |

---

## 🚀 First Steps / Primeros pasos

### EN
1. Open http://localhost:3000 — Open WebUI
2. Register your account (first user becomes admin)
3. Select `qwen2.5-coder:7b` as the active model
4. Try: "Write a Python function that reads a CSV file"

### ES
1. Abre http://localhost:3000 — Open WebUI
2. Regístrate (el primer usuario es admin)
3. Selecciona `qwen2.5-coder:7b` como modelo activo
4. Prueba: "Escribe una función en Python que lea un archivo CSV"

---

## 🔧 Commands / Comandos

```bash
make status      # Check stack status / Ver estado
make logs        # View live logs / Ver logs en vivo
make update      # Update everything / Actualizar todo
make stop        # Stop services / Detener servicios
make start       # Start services / Iniciar servicios
make restart     # Restart services / Reiniciar servicios
make uninstall   # Clean removal / Desinstalar
make backup      # Backup configs / Respaldar configuración
```

---

## 📖 Guides / Guías

| Guide / Guía | Description / Descripción |
|---|---|
| [Quick Start](docs/GUIDE_QUICKSTART.md) | First 5 minutes after install |
| [Code with AI](docs/GUIDE_CODE.md) | Programming with local models |
| [Design Logos](docs/GUIDE_LOGOS.md) | Logo generation workflow |
| [Web Design](docs/GUIDE_WEB.md) | Web page design pipeline |
| [Mobile Apps](docs/GUIDE_MOBILE.md) | Mobile app design |
| [Writing](docs/GUIDE_WRITING.md) | Documentation and guides |
| [RAG](docs/GUIDE_RAG.md) | Chat with your documents |
| [CodeNest](docs/GUIDE_CODENEST.md) | Dev Command Center |
| [Design Guide](docs/GUIDE_DESIGN.md) | Visual design overview |
| [Maintenance](docs/GUIDE_MAINTENANCE.md) | Backups, updates, cleanup |
| [Windows (WSL2)](docs/WINDOWS.md) | Setup on Windows |
| [Profiles](docs/PROFILES.md) | Profile comparison |
| [Troubleshooting](docs/TROUBLESHOOTING.md) | Common issues |
| [FAQ](docs/FAQ.md) | Frequently asked |

---

## 🔌 Integration / Integraciones

| Tool / Herramienta | Connection / Conexión | Auto? |
|---|---|---|
| **OpenCode** | `~/.config/opencode/opencode.json` → `:11434/v1` | ✅ |
| **VS Code + Continue** | Extension config → `:11434/v1` | ✅ |
| **CodeNest** | Auto-discovery via `host.docker.internal:11434` | ✅ |
| **Open WebUI** | Internal DNS `http://ollama:11434` | ✅ |
| **Open WebUI → ComfyUI** | `COMFYUI_BASE_URL=http://comfyui:8188` | ✅ |

---

## 🧠 Models / Modelos

| Model | RAM (Q4) | Purpose / Propósito | Profile |
|---|---|---|---|
| `qwen2.5-coder:7b` | ~5 GB | Code + docs in Spanish | bare |
| `qwen2.5-vl:7b` | ~6 GB | Vision (screenshots, mockups) | standard |
| `llama3.2:3b` | ~2.5 GB | Quick tasks | standard |
| `nomic-embed-text` | ~0.5 GB | RAG embeddings | standard |
| `deepseek-coder-v2-lite:16b` | ~10 GB | Complex mobile code (MoE) | full |

---

## 🎨 LoRAs for ComfyUI

| LoRA | Purpose / Propósito |
|---|---|
| Logo Design V2 | Professional logos |
| Flat Design Logo | Modern flat logos |
| Minimalist Logo | Minimalist logos |
| website-ui-sdxl-lora | Web UI mockups |

---

## 📁 Project Structure / Estructura

```
zen-ai-stack/
├── docker-compose.yml       # Core services
├── .env.example             # Environment template
├── Makefile                 # Convenience commands
├── scripts/
│   ├── setup.sh             # ★ Main installer
│   ├── update.sh            # Update everything
│   ├── uninstall.sh         # Clean removal
│   ├── status.sh            # Verify services
│   ├── backup.sh            # Backup configs
│   └── lib/                 # Shared functions
├── configs/                 # Configuration templates
├── docs/                    # User guides
├── loras/                   # LoRA download URLs
└── tools/                   # screenshot-to-code, etc.
```

---

## 📄 License / Licencia

MIT — See [LICENSE](LICENSE)

## 🤝 Contributing / Contribuir

See [CONTRIBUTING.md](CONTRIBUTING.md)
