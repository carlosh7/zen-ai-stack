# Quick Start Guide / Guía de Inicio Rápido

## EN — First 5 Minutes After Install

1. **Open Open WebUI** at http://localhost:3000
2. **Register** your account (first user becomes admin)
3. **Select model** `qwen2.5-coder:7b` in the top dropdown
4. **Try these prompts:**
   - "Write a Python function that reads a CSV and calculates averages"
   - "Explain this code in Spanish: `const x = await fetch(url)`"
   - "Create a simple HTML page with a navigation bar"

5. **Generate an image:** Type `/image a minimalist logo with a mountain`
6. **Open CodeNest** (if installed) at http://localhost:8000
7. **Open VS Code** and start Continue with `Ctrl+I`

## ES — Primeros 5 Minutos Después de Instalar

1. **Abre Open WebUI** en http://localhost:3000
2. **Regístrate** (el primer usuario es admin)
3. **Selecciona** `qwen2.5-coder:7b` como modelo
4. **Prueba estos prompts:**
   - "Escribe una función en Python que lea un CSV y calcule promedios"
   - "Explica este código en español: `const x = await fetch(url)`"
   - "Crea una página HTML simple con una barra de navegación"

5. **Genera una imagen:** Escribe `/image un logo minimalista con una montaña`
6. **Abre CodeNest** (si está instalado) en http://localhost:8000
7. **Abre VS Code** y usa Continue con `Ctrl+I`

## Troubleshooting Quick / Solución Rápida

| Problem / Problema | Solution / Solución |
|---|---|
| Open WebUI not loading | `make logs` to check errors |
| Models not responding | `curl http://localhost:11434/api/tags` |
| Docker permission denied | Re-login or `sudo usermod -aG docker $USER` |
