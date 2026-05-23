# Troubleshooting / Solución de Problemas

## EN

### Docker Issues

**Permission denied when running Docker commands**
```bash
# Add your user to the docker group
sudo usermod -aG docker $USER
# Then log out and back in
```

**Port already in use**
Check which service is using the port:
```bash
sudo ss -tlnp | grep :11434
```
Change the port in `.env` and restart:
```bash
HOST_PORT_OLLAMA=11435
```

### Model Issues

**Ollama not responding**
```bash
# Check if Ollama container is running
docker ps | grep zen-ollama

# Check logs
docker compose logs ollama

# Restart Ollama
docker compose restart ollama
```

**Model download failed**
The script retries 3 times automatically. If it still fails:
```bash
# Download manually
ollama pull qwen2.5-coder:7b
```

### Open WebUI Issues

**Can't connect to ComfyUI**
1. Verify ComfyUI is running: `docker ps | grep zen-comfyui`
2. Check Open WebUI env vars in docker-compose.yml
3. Restart Open WebUI: `docker compose restart open-webui`

**Can't generate images**
1. Ensure `ENABLE_IMAGE_GENERATION=true` in `.env`
2. Check that ComfyUI base URL is correct
3. Verify ComfyUI has a model loaded

### VS Code Issues

**Continue not detecting models**
1. Check that Continue is installed: `code --list-extensions | grep continue`
2. Verify the config in VS Code settings
3. Ensure Ollama is running: `curl http://localhost:11434/api/tags`

### CodeNest Issues

**CodeNest not detecting Ollama**
1. Ensure both stacks are running
2. Check `docker ps` for both codenest and zen containers
3. CodeNest auto-discovers on port scan — give it a moment
4. Restart CodeNest backend: `cd ~/CodeNest && docker compose restart backend`

## ES

### Problemas con Docker

**Permiso denegado al ejecutar comandos Docker**
```bash
# Añade tu usuario al grupo docker
sudo usermod -aG docker $USER
# Luego cierra sesión y vuelve a entrar
```

**Puerto ya está en uso**
Verifica qué servicio usa el puerto:
```bash
sudo ss -tlnp | grep :11434
```
Cambia el puerto en `.env` y reinicia:
```bash
HOST_PORT_OLLAMA=11435
```

### Problemas con Modelos

**Ollama no responde**
```bash
# Verifica que el contenedor esté corriendo
docker ps | grep zen-ollama

# Revisa logs
docker compose logs ollama

# Reinicia Ollama
docker compose restart ollama
```

**Descarga de modelo falló**
El script reintenta 3 veces automáticamente. Si aún falla:
```bash
# Descarga manual
ollama pull qwen2.5-coder:7b
```

### Problemas con Open WebUI

**No se conecta a ComfyUI**
1. Verifica que ComfyUI esté corriendo
2. Revisa las env vars en docker-compose.yml
3. Reinicia Open WebUI

**No puede generar imágenes**
1. Asegúrate de que `ENABLE_IMAGE_GENERATION=true` en `.env`
2. Verifica que la URL de ComfyUI sea correcta
3. Asegúrate de que ComfyUI tenga un modelo cargado
