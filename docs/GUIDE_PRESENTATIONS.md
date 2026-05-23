# Create Presentations & Manuals with AI / Crear Presentaciones y Manuales con IA

## EN

This guide shows how to create professional presentations, user manuals, and guides using your local AI stack.

### Tools Available

| Tool | Installed | Purpose |
|---|---|---|
| `qwen2.5:14b` | ✅ | Writing content, structure |
| ComfyUI (http://localhost:8188) | ✅ | Generate images, diagrams, illustrations |
| SDXL checkpoint | ⬇️ Downloading | High-quality image generation |
| Pandoc | ✅ | Markdown → PDF / PPTX / HTML |
| Marp CLI | ✅ | Markdown → Presentation slides |
| LoRAs (logos, UI) | ✅ (reinstall needed) | Logo and UI mockup generation |

### Workflow 1: Generate a Presentation (HTML+CSS)

**Step 1:** Ask the model to create a complete presentation in HTML+CSS:

Open http://localhost:3003 (Open WebUI), select `qwen2.5:14b`, and use this prompt:

```
Create a complete HTML presentation about [YOUR TOPIC].
Requirements:
- 8 slides with navigation (next/prev buttons)
- Professional color scheme, modern design
- Each slide has a title, content, and optional image placeholder
- Include a "Download PDF" button using window.print()
- CSS @media print rules for clean PDF output
- Dark/light mode toggle
- All in a single self-contained HTML file, no external dependencies
- Responsive design (works on mobile and desktop)
```

The model will generate a single `.html` file. Save it and open in browser.

**Step 2:** Generate images for the presentation:

```
/image professional slide background, blue gradient, abstract tech pattern, clean
```

Images are saved in ComfyUI's output folder at `~/zen-ai-stack/comfyui/output/`.

**Step 3:** Insert images into the HTML and re-save.

### Workflow 2: Generate a PDF Manual

**Step 1:** Generate content in Markdown:

Open Open WebUI with `qwen2.5:14b`:

```
Write a user manual for [software/product] in Markdown format.
Include: installation steps, configuration, usage, troubleshooting, FAQ.
Structure with headings (##), lists, code blocks, and image placeholders.
```

**Step 2:** Generate supporting images with ComfyUI:

```
/image "screenshot of software interface, clean UI, no text"
/image "diagram of system architecture, arrows and labels"
```

**Step 3:** Convert Markdown to PDF:

```bash
pandoc manual.md -o manual.pdf --metadata title="User Manual"
```

Or to PPTX:

```bash
pandoc manual.md -o manual.pptx
```

### Workflow 3: Generate Presentation Slides (Marp)

**Step 1:** Create Marp-format Markdown:

```
Generate a Marp presentation about [topic].
Use --- to separate slides.
Include: title slide, agenda, 6 content slides, closing slide.
```

**Step 2:** Convert to presentation:

```bash
marp slides.md --pdf -o presentation.pdf
marp slides.md --pptx -o presentation.pptx
```

### Prompt Templates

#### Template: Complete Presentation

Copy this prompt to Open WebUI:

```text
Create a complete HTML presentation about [YOUR TOPIC].

Structure:
- Slide 1: Title + subtitle
- Slide 2: Agenda / Overview
- Slides 3-7: Content (one concept per slide)
- Slide 8: Conclusion / Next steps

Design:
- Modern, clean, professional
- Color scheme: [describe colors, e.g. blue/white/gray]
- Font: system fonts (no external)
- Responsive
- Navigation arrows
- Slide counter

Features:
- "Download PDF" button using window.print()
- CSS @media print with page-break-after for each slide
- Dark/light mode toggle
- Image placeholders where relevant

Output a single self-contained HTML file.
```

#### Template: User Manual Page

```text
Create an HTML user manual page for [software/product].

Include sections:
1. Overview with description
2. Installation requirements
3. Step-by-step setup with numbered instructions
4. Configuration options table
5. Common tasks (3-4 procedures)
6. Troubleshooting FAQ table
7. Support contact

Design a clean documentation layout with:
- Sidebar table of contents
- Breadcrumb navigation
- Code blocks with syntax highlighting
- Info/warning callout boxes
- Print-friendly CSS
- "Download as PDF" button
```

### Image Generation Tips for Manuals

| Prompt Style | Best for |
|---|---|
| `"screenshot of [software] dashboard, clean modern UI"` | Software documentation |
| `"diagram of network architecture, connected nodes, labels"` | Technical diagrams |
| `"flowchart showing [process], arrows, decision points"` | Process documentation |
| `"icon for [topic], flat design, blue, white background"` | Section icons |
| `"illustration of [concept], isometric, technical style"` | Concept illustrations |

### Converting to Different Formats

```bash
# Markdown → PDF (general documents)
pandoc document.md -o document.pdf

# Markdown → PPTX (PowerPoint)
pandoc document.md -o document.pptx

# Markdown → HTML (web page)
pandoc document.md -o document.html

# Marp Markdown → PDF (presentations)
marp slides.md --pdf -o presentation.pdf

# Marp Markdown → PPTX
marp slides.md --pptx -o presentation.pptx

# Marp Markdown → HTML (interactive web slides)
marp slides.md -o presentation.html
```

---

## ES

Esta guía explica cómo crear presentaciones profesionales, manuales de usuario y guías usando tu stack de IA local.

### Herramientas Disponibles

| Herramienta | Instalada | Propósito |
|---|---|---|
| `qwen2.5:14b` | ✅ | Redactar contenido, estructura |
| ComfyUI (http://localhost:8188) | ✅ | Generar imágenes, diagramas |
| Checkpoint SDXL | ⬇️ Descargando | Imágenes de alta calidad |
| Pandoc | ✅ | Markdown → PDF / PPTX / HTML |
| Marp CLI | ✅ | Markdown → Diapositivas |
| LoRAs (logos, UI) | ✅ (reinstalar) | Logos y mockups |

### Flujo 1: Crear una Presentación (HTML+CSS)

**Paso 1:** Pide al modelo que cree una presentación completa en HTML+CSS:

Abre http://localhost:3003 (Open WebUI), selecciona `qwen2.5:14b`, y usa este prompt:

```
Crea una presentación HTML completa sobre [TU TEMA].
Requisitos:
- 8 diapositivas con navegación (anterior/siguiente)
- Esquema de colores profesional, diseño moderno
- Cada diapositiva con título, contenido y placeholder de imagen
- Botón "Descargar PDF" usando window.print()
- CSS @media print para PDF limpio
- Modo oscuro/claro
- Un solo archivo HTML autónomo, sin dependencias externas
- Diseño responsive
```

Guarda el archivo `.html` generado y ábrelo en el navegador.

**Paso 2:** Genera imágenes con:

```
/image fondo profesional para presentación, degradado azul, patrón abstracto tech
```

**Paso 3:** Inserta las imágenes en el HTML.

### Flujo 2: Crear un Manual en PDF

**Paso 1:** Genera contenido en Markdown:

```
Escribe un manual de usuario para [software/producto] en formato Markdown.
Incluye: instalación, configuración, uso, solución de problemas, FAQ.
Estructura con headings (##), listas, bloques de código y placeholders de imágenes.
```

**Paso 2:** Genera imágenes de apoyo con ComfyUI.

**Paso 3:** Convierte a PDF:

```bash
pandoc manual.md -o manual.pdf
```

### Plantillas de Prompt

#### Presentación Completa

```text
Crea una presentación HTML completa sobre [TU TEMA].

Estructura:
- Diapositiva 1: Título + subtítulo
- Diapositiva 2: Agenda / Vista general
- Diapositivas 3-7: Contenido (un concepto por diapositiva)
- Diapositiva 8: Conclusión

Diseño:
- Moderno, limpio, profesional
- Esquema de colores: [describe colores]
- Responsive
- Flechas de navegación
- Contador de diapositivas

Características:
- Botón "Descargar PDF" con window.print()
- CSS @media print con page-break-after
- Alternar modo oscuro/claro
- Un solo archivo HTML autónomo
```
