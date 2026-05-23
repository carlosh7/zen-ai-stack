# Maintenance Guide / Guía de Mantenimiento

## EN

### Daily Operations

**Check status:**
```bash
make status
```

**View logs:**
```bash
make logs
# Or for a specific service:
docker compose logs ollama
docker compose logs open-webui
```

**Stop/Start:**
```bash
make stop
make start
```

### Updates

**Update everything:**
```bash
make update
```

**Update only models:**
```bash
ollama pull qwen2.5-coder:7b
```

**Update only Docker images:**
```bash
docker compose pull
docker compose up -d
```

### Backups
```bash
make backup
# Backups are stored in ~/zen-ai-stack-backups/
```

### Offline Bundle

**Export bundle (share with others):**
```bash
make export-bundle
# Creates models-bundle.tar.gz with all Docker images + models + tools
# ~50 GB total. Share via USB drive, cloud, or torrent.
```

**Import bundle (install without internet):**
```bash
# Place models-bundle.tar.gz in zen-ai-stack folder, then:
./scripts/setup.sh --offline
```

### Cleanup

**Remove unused Docker images:**
```bash
docker image prune -a
```

**Remove unused models:**
```bash
ollama rm llama3.2:3b
```

### Uninstall
```bash
make uninstall
```

## ES

### Operaciones Diarias

**Ver estado:**
```bash
make status
```

**Ver logs:**
```bash
make logs
# O para un servicio específico:
docker compose logs ollama
docker compose logs open-webui
```

**Detener/Iniciar:**
```bash
make stop
make start
```

### Actualizaciones

**Actualizar todo:**
```bash
make update
```

**Actualizar solo modelos:**
```bash
ollama pull qwen2.5-coder:7b
```

**Actualizar solo imágenes Docker:**
```bash
docker compose pull
docker compose up -d
```

### Respaldos
```bash
make backup
# Los respaldos se guardan en ~/zen-ai-stack-backups/
```

### Bundle Offline

**Exportar bundle (compartir con otros):**
```bash
make export-bundle
# Crea models-bundle.tar.gz con imágenes Docker + modelos + herramientas
# ~50 GB. Comparte via USB, nube o torrent.
```

**Importar bundle (instalar sin internet):**
```bash
# Coloca models-bundle.tar.gz en la carpeta de zen-ai-stack, luego:
./scripts/setup.sh --offline
```

### Limpieza

**Eliminar imágenes Docker no usadas:**
```bash
docker image prune -a
```

**Eliminar modelos no usados:**
```bash
ollama rm llama3.2:3b
```

### Desinstalar
```bash
make uninstall
```
