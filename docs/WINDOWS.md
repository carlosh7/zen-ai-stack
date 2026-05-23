# Windows Installation (WSL2) / Instalación en Windows (WSL2)

## EN

### Requirements
- Windows 11 with WSL2 enabled
- Docker Desktop for Windows with WSL2 backend
- At least 32 GB RAM recommended
- 60 GB free disk space

### Step-by-Step

**1. Install WSL2**
Open PowerShell as Administrator:
```powershell
wsl --install -d Ubuntu
```

**2. Install Docker Desktop**
1. Download from https://www.docker.com/products/docker-desktop/
2. Install and enable WSL2 backend (Settings → Resources → WSL Integration)
3. Restart Docker Desktop

**3. Install zen-ai-stack inside WSL2**
```bash
# Open WSL2 terminal
wsl

# Clone and run
git clone https://github.com/carlosh7/zen-ai-stack.git
cd zen-ai-stack
cp .env.example .env
./scripts/setup.sh
```

**4. Access services**
All services are accessible from Windows browser at localhost:
- Open WebUI: http://localhost:3000
- Ollama API: http://localhost:11434
- ComfyUI: http://localhost:8188
- Portainer: https://localhost:9443

### Known Limitations
- GPU acceleration is limited in WSL2
- ComfyUI image generation will be slower than native Linux
- File access between Windows and WSL2 can be slower with Docker volumes

## ES

### Requisitos
- Windows 11 con WSL2 habilitado
- Docker Desktop para Windows con backend WSL2
- Al menos 32 GB RAM recomendado
- 60 GB de espacio libre en disco

### Paso a Paso

**1. Instalar WSL2**
Abre PowerShell como Administrador:
```powershell
wsl --install -d Ubuntu
```

**2. Instalar Docker Desktop**
1. Descarga desde https://www.docker.com/products/docker-desktop/
2. Instala y habilita el backend WSL2 (Settings → Resources → WSL Integration)
3. Reinicia Docker Desktop

**3. Instalar zen-ai-stack dentro de WSL2**
```bash
# Abre terminal WSL2
wsl

# Clona y ejecuta
git clone https://github.com/carlosh7/zen-ai-stack.git
cd zen-ai-stack
cp .env.example .env
./scripts/setup.sh
```

**4. Acceder a los servicios**
Todos los servicios son accesibles desde el navegador de Windows en localhost:
- Open WebUI: http://localhost:3000
- Ollama API: http://localhost:11434
- ComfyUI: http://localhost:8188
- Portainer: https://localhost:9443

### Limitaciones Conocidas
- La aceleración por GPU es limitada en WSL2
- La generación de imágenes en ComfyUI será más lenta que en Linux nativo
- El acceso a archivos entre Windows y WSL2 puede ser más lento
