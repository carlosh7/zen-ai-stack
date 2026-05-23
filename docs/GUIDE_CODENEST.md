# Using CodeNest with zen-ai-stack / Usar CodeNest con zen-ai-stack

## EN

### Integration
CodeNest auto-discovers Ollama running on localhost:11434. No manual configuration needed.

### Setup
If you installed CodeNest via setup.sh (`--full` profile or auto-detect), it should already be running.

```bash
# Check CodeNest status
docker ps | grep codenest

# Access CodeNest
open http://localhost:8000
```

### Using Local Models in CodeNest
1. Open CodeNest in your browser
2. Go to Settings → AI Providers
3. You should see "Ollama (Local)" already detected
4. Select `qwen2.5-coder:7b` as your active model
5. Start chatting — CodeNest will use your local Ollama

### Troubleshooting
**If CodeNest doesn't detect Ollama:**
1. Ensure zen-ai-stack is running: `make status`
2. Check Ollama is responding: `curl http://localhost:11434/api/tags`
3. Restart CodeNest: `cd ~/CodeNest && docker compose restart backend`

## ES

### Integración
CodeNest descubre automáticamente Ollama en localhost:11434. No necesita configuración manual.

### Configuración
Si instalaste CodeNest vía setup.sh (perfil `--full` o detección automática), ya debería estar funcionando.

```bash
# Ver estado de CodeNest
docker ps | grep codenest

# Acceder a CodeNest
open http://localhost:8000
```

### Usar Modelos Locales en CodeNest
1. Abre CodeNest en tu navegador
2. Ve a Settings → AI Providers
3. Deberías ver "Ollama (Local)" ya detectado
4. Selecciona `qwen2.5-coder:7b` como modelo activo
5. Empieza a chatear — CodeNest usará tu Ollama local
