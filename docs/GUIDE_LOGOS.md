# Logo Design with AI / Diseñar Logos con IA

## EN

### Tools Needed
- ComfyUI (http://localhost:8188)
- SDXL Logo LoRAs (auto-downloaded by setup.sh)
- VTracer (for vectorization)
- Inkscape (for final editing)

### Workflow

**Step 1: Generate logo with ComfyUI**
1. Open http://localhost:8188
2. Load a default SDXL workflow
3. Add a LoRA loader node with one of the logo LoRAs
4. Prompt: "logo, flat design, minimalist, technology company, blue and white, simple shapes"
5. Generate and save the PNG

**Step 2: Vectorize with VTracer**
```bash
vtracer --input logo.png --output logo.svg --colormode color --filter_speckle 10
```

**Step 3: Edit in Inkscape**
```bash
inkscape logo.svg
```

**Step 4: Export**
- For web: SVG or PNG
- For print: PDF or EPS

### Available Logo LoRAs
- Logo Design V2 SDXL — Professional corporate logos
- Flat Design Logo SDXL — Modern flat logos
- Minimalist Logo SDXL — Clean minimalist logos

### Tips
- Keep prompts simple: "logo, [style], [subject], [colors], white background"
- Generate multiple variations and pick the best
- Always vectorize final output for scalability

## ES

### Herramientas Necesarias
- ComfyUI (http://localhost:8188)
- SDXL LoRAs de logos (descargados por setup.sh)
- VTracer (para vectorizar)
- Inkscape (para edición final)

### Flujo de Trabajo

**Paso 1: Generar logo con ComfyUI**
1. Abre http://localhost:8188
2. Carga un workflow SDXL por defecto
3. Añade un nodo LoRA loader con una de las LoRAs de logo
4. Prompt: "logo, flat design, minimalist, technology company, blue and white, simple shapes"
5. Genera y guarda el PNG

**Paso 2: Vectorizar con VTracer**
```bash
vtracer --input logo.png --output logo.svg --colormode color --filter_speckle 10
```

**Paso 3: Editar en Inkscape**
```bash
inkscape logo.svg
```

**Paso 4: Exportar**
- Para web: SVG o PNG
- Para impresión: PDF o EPS

### LoRAs de Logo Disponibles
- Logo Design V2 SDXL — Logos corporativos profesionales
- Flat Design Logo SDXL — Logos planos modernos
- Minimalist Logo SDXL — Logos minimalistas

### Consejos
- Mantén los prompts simples: "logo, [estilo], [sujeto], [colores], fondo blanco"
- Genera múltiples variaciones y elige la mejor
- Siempre vectoriza el resultado final para escalabilidad
