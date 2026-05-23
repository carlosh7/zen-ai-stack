# Code with AI / Programar con IA

## EN

### Using OpenCode
OpenCode connects directly to Ollama and can execute commands, generate code, and manage projects.

```bash
# Open OpenCode in your terminal
opencode

# Ask it to write code
opencode "Create a React component for a search bar"

# Or use inline mode
opencode --model qwen2.5-coder:7b "Refactor this function:" < file.py
```

### Using VS Code + Continue
1. Open VS Code
2. Press `Ctrl+I` to open Continue
3. Select `Qwen 2.5 Coder 7B` as the model
4. Highlight code and ask for refactoring, explanation, or changes

### Using Open WebUI
- http://localhost:3000 — Chat interface for code generation
- Upload entire files for analysis
- Ask for code reviews, debugging help, or architecture advice

### Tips
- `qwen2.5-coder:7b` is your best model for coding tasks
- Use `deepseek-coder-v2:16b` for complex multi-file projects
- For quick questions, use `llama3.2:3b` (fastest)

## ES

### Usando OpenCode
OpenCode se conecta directamente a Ollama y puede ejecutar comandos, generar código y gestionar proyectos.

```bash
# Abre OpenCode en tu terminal
opencode

# Pídele que escriba código
opencode "Crea un componente React para una barra de búsqueda"

# O usa modo inline
opencode --model qwen2.5-coder:7b "Refactoriza esta función:" < archivo.py
```

### Usando VS Code + Continue
1. Abre VS Code
2. Presiona `Ctrl+I` para abrir Continue
3. Selecciona `Qwen 2.5 Coder 7B` como modelo
4. Selecciona código y pide refactorización, explicación o cambios

### Usando Open WebUI
- http://localhost:3000 — Chat para generación de código
- Sube archivos completos para análisis
- Pide revisiones de código, ayuda con debugging o consejos de arquitectura

### Consejos
- `qwen2.5-coder:7b` es tu mejor modelo para tareas de código
- Usa `deepseek-coder-v2:16b` para proyectos complejos multi-archivo
- Para preguntas rápidas, usa `llama3.2:3b` (el más rápido)
