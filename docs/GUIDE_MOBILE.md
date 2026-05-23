# Mobile App Design with AI / Diseñar Apps Móviles con IA

## EN

### Tools Needed
- Qwen2.5-Coder 7B (for Flutter, Kotlin, Swift code)
- Qwen2.5-VL 7B (for understanding screenshots)
- ComfyUI + SDXL (for phone UI mockups)
- deepseek-coder-v2-lite:16b (for complex mobile code)

### Workflow

**Step 1: Design the UI**
Use ComfyUI to generate phone app screens:
```
Prompt: "mobile app screen, ios style, user profile page with avatar, name, settings list, clean design"
```

**Step 2: Describe the UI with vision model**
```bash
# Upload the screenshot to Open WebUI and ask:
"Describe this mobile UI in detail, including all elements and their layout"
```

**Step 3: Generate the code**
```
Prompt: "Create a Flutter widget for this user profile screen with:
- Circular avatar at top center
- Name and email below
- List of settings options with icons
- Clean Material Design"
```

### Framework Options

| Framework | Best Model | Command |
|---|---|---|
| Flutter/Dart | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |
| Kotlin/Jetpack | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |
| Swift/SwiftUI | deepseek-coder-v2-lite | ollama run deepseek-coder-v2-lite:16b |
| React Native | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |

### Tips
- Start with screenshots of apps you like → ask the vision model to describe them
- Always specify the framework in your prompt
- For complex business logic, break it into smaller functions
- Test generated code in an emulator before deploying

## ES

### Herramientas Necesarias
- Qwen2.5-Coder 7B (para código Flutter, Kotlin, Swift)
- Qwen2.5-VL 7B (para entender capturas de pantalla)
- ComfyUI + SDXL (para mockups de pantallas)
- deepseek-coder-v2-lite:16b (para código mobile complejo)

### Flujo de Trabajo

**Paso 1: Diseñar la UI**
Usa ComfyUI para generar pantallas de app:
```
Prompt: "mobile app screen, ios style, user profile page with avatar, name, settings list, clean design"
```

**Paso 2: Describir la UI con el modelo de visión**
```bash
# Sube la captura a Open WebUI y pregunta:
"Describe esta UI móvil en detalle, incluyendo todos los elementos y su layout"
```

**Paso 3: Generar el código**
```
Prompt: "Crea un widget de Flutter para esta pantalla de perfil con:
- Avatar circular en la parte superior
- Nombre y email debajo
- Lista de opciones de configuración con iconos
- Material Design limpio"
```

### Opciones de Framework

| Framework | Mejor Modelo | Comando |
|---|---|---|
| Flutter/Dart | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |
| Kotlin/Jetpack | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |
| Swift/SwiftUI | deepseek-coder-v2-lite | ollama run deepseek-coder-v2-lite:16b |
| React Native | qwen2.5-coder:7b | ollama run qwen2.5-coder:7b |

### Consejos
- Empieza con capturas de apps que te gusten → pide al modelo de visión que las describa
- Siempre especifica el framework en tu prompt
- Para lógica de negocio compleja, divídela en funciones más pequeñas
- Prueba el código en un emulador antes de desplegar
