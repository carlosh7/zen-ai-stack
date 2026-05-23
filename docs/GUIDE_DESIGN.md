# Visual Design Overview / Resumen de Diseño Visual

## EN

### What You Can Create

| Type / Tipo | Tool | Model/LoRA |
|---|---|---|
| Logos | ComfyUI | Logo Design V2 SDXL, Flat Design Logo, Minimalist Logo |
| Web mockups | ComfyUI | website-ui-sdxl-lora |
| App screens | ComfyUI | SDXL base + prompting |
| App icons | ComfyUI | SDXL base + prompting |
| Diagrams | ComfyUI | SDXL base |
| Technical illustrations | ComfyUI | SDXL base |

### Pipeline Overview

```
Prompt → ComfyUI → PNG → VTracer → SVG → Inkscape → Final
                                    ↕ (vectorize)
```

### Tips
- Use `--lowvram-mode` with ComfyUI (auto-configured)
- Generated images are saved in ComfyUI's output directory
- For scalable graphics, always vectorize with VTracer
- For print-ready designs, export from Inkscape as PDF

## ES

### Qué Puedes Crear

| Tipo / Type | Herramienta | Modelo/LoRA |
|---|---|---|
| Logos | ComfyUI | Logo Design V2 SDXL, Flat Design Logo, Minimalist Logo |
| Mockups web | ComfyUI | website-ui-sdxl-lora |
| Pantallas de app | ComfyUI | SDXL base + prompting |
| Iconos de app | ComfyUI | SDXL base + prompting |
| Diagramas | ComfyUI | SDXL base |
| Ilustraciones técnicas | ComfyUI | SDXL base |

### Pipeline General

```
Prompt → ComfyUI → PNG → VTracer → SVG → Inkscape → Final
                                    ↕ (vectorizar)
```

### Consejos
- Usa `--lowvram-mode` con ComfyUI (configuración automática)
- Las imágenes se guardan en el directorio de output de ComfyUI
- Para gráficos escalables, siempre vectoriza con VTracer
- Para diseños listos para impresión, exporta desde Inkscape como PDF
