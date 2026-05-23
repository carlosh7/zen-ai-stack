# FAQ / Preguntas Frecuentes

## EN

### General

**Q: What is zen-ai-stack?**
A: A local AI stack that runs 100% offline on your laptop. It includes LLMs, image generation, and integrations with editors.

**Q: Do I need internet?**
A: Only for installation (downloading models and Docker images). After that, everything runs offline.

**Q: How much RAM do I need?**
A: 16 GB minimum, 32 GB recommended.

**Q: Does it work on Windows?**
A: Yes, via WSL2. See [WINDOWS.md](WINDOWS.md).

**Q: Is GPU required?**
A: No, everything runs on CPU. GPU acceleration is optional and not yet configured.

### Models

**Q: Can I add more models?**
A: Yes: `ollama pull <model-name>`

**Q: Can I remove models?**
A: Yes: `ollama rm <model-name>`

**Q: Why 5 models?**
A: Each model is specialized: coding (qwen2.5-coder), vision (llama3.2-vision), fast (llama3.2), embeddings (nomic), complex code (deepseek-coder-v2).

### Docker

**Q: How do I stop the stack?**
A: `make stop`

**Q: How do I update the stack?**
A: `make update`

**Q: Where is my data stored?**
A: In Docker volumes. Backup with `make backup`.

### CodeNest

**Q: Is CodeNest required?**
A: No. CodeNest is optional (included in `--full` profile or auto-detected).

**Q: Does CodeNest work with the local models?**
A: Yes. CodeNest auto-discovers Ollama on localhost:11434.

## ES

### General

**P: ¿Qué es zen-ai-stack?**
R: Un stack de IA local que corre 100% offline en tu portátil. Incluye LLMs, generación de imágenes e integraciones con editores.

**P: ¿Necesito internet?**
R: Solo para la instalación (descargar modelos e imágenes Docker). Después, todo funciona offline.

**P: ¿Cuánta RAM necesito?**
R: Mínimo 16 GB, recomendado 32 GB.

**P: ¿Funciona en Windows?**
R: Sí, mediante WSL2. Ver [WINDOWS.md](WINDOWS.md).

**P: ¿Se necesita GPU?**
R: No, todo funciona en CPU. La aceleración GPU es opcional.

### Modelos

**P: ¿Puedo añadir más modelos?**
R: Sí: `ollama pull <nombre-del-modelo>`

**P: ¿Puedo eliminar modelos?**
R: Sí: `ollama rm <nombre-del-modelo>`

**P: ¿Por qué 5 modelos?**
R: Cada modelo está especializado: código (qwen2.5-coder), visión (llama3.2-vision), rápido (llama3.2), embeddings (nomic), código complejo (deepseek-coder-v2).

### Docker

**P: ¿Cómo detengo el stack?**
R: `make stop`

**P: ¿Cómo actualizo el stack?**
R: `make update`

**P: ¿Dónde se guardan mis datos?**
R: En volúmenes Docker. Respáldalos con `make backup`.
