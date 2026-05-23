# Web Page Design with AI / Diseñar Páginas Web con IA

## EN

### Tools Needed
- Qwen2.5-Coder 7B (for HTML/CSS/JS code)
- ComfyUI + website-ui-lora (for visual mockups)
- screenshot-to-code (optional, for screenshot→code)

### Workflow

**Option A: Code-first (recommended)**
1. Use Open WebUI or OpenCode to generate HTML/CSS
2. Prompt: "Create a responsive landing page for a coffee shop with hero, features, and contact sections"
3. Save the generated code
4. Open in browser or VS Code

**Option B: Design-first (visual mockup → code)**
1. Generate a mockup in ComfyUI with website-ui-lora
2. Prompt: "a website screenshot <s0><s1> modern dashboard design"
3. Save the generated image
4. Optionally, use screenshot-to-code to convert to HTML

**Option C: Screenshot-to-code**
```bash
cd tools/screenshot-to-code
docker compose up -d
# Open http://localhost:5173
# Upload a screenshot → get HTML/CSS
```

### Example Prompts
- "Create a responsive navigation bar with logo and 4 links"
- "Design a pricing table with 3 tiers (Basic, Pro, Enterprise)"
- "Build a contact form with name, email, message fields"
- "Generate a hero section with a headline, subtitle, and CTA button"

### Tips
- `qwen2.5-coder:7b` handles all frontend frameworks (React, Vue, Tailwind, Bootstrap)
- For complex layouts, describe the structure first, then the styling
- Always test generated code in a browser before deploying

## ES

### Herramientas Necesarias
- Qwen2.5-Coder 7B (para código HTML/CSS/JS)
- ComfyUI + website-ui-lora (para mockups visuales)
- screenshot-to-code (opcional, para convertir capturas en código)

### Flujo de Trabajo

**Opción A: Código primero (recomendado)**
1. Usa Open WebUI o OpenCode para generar HTML/CSS
2. Prompt: "Crea una landing page responsiva para una cafetería con secciones hero, características y contacto"
3. Guarda el código generado
4. Abre en navegador o VS Code

**Opción B: Diseño primero (mockup visual → código)**
1. Genera un mockup en ComfyUI con website-ui-lora
2. Prompt: "a website screenshot <s0><s1> modern dashboard design"
3. Guarda la imagen generada
4. Opcionalmente, usa screenshot-to-code para convertir a HTML

**Opción C: Captura a código**
```bash
cd tools/screenshot-to-code
docker compose up -d
# Abre http://localhost:5173
# Sube una captura → obtén HTML/CSS
```

### Ejemplos de Prompts
- "Crea una barra de navegación responsiva con logo y 4 enlaces"
- "Diseña una tabla de precios con 3 niveles (Básico, Pro, Empresa)"
- "Construye un formulario de contacto con nombre, email, mensaje"
- "Genera una sección hero con título, subtítulo y botón CTA"

### Consejos
- `qwen2.5-coder:7b` maneja todos los frameworks frontend (React, Vue, Tailwind, Bootstrap)
- Para layouts complejos, describe primero la estructura, luego el estilo
- Siempre prueba el código en un navegador antes de desplegar
