# ACTION_PLAN.md — zen-ai-stack

Fecha: 2026-08-21 · Origen: AUDIT_REPORT.md (score 63/100) · Contexto: proyecto absorbido por CodeNest → aplicar solo si se revive el stack o al portarlo a CodeNest.

## Prioridad P0 — Corregir bugs que rompen confianza (≈ 2–4 h)

1. ~~**Arreglar `scripts/backup.sh:15,21,27`**~~ ✅ **Ejecutado ago-2026**: descubrimiento dinámico por label `com.docker.compose.project`; testeado en runtime con volumen ficticio `zen-ai-stack_testvol` → genera `testvol.tar.gz`. shellcheck limpio.
2. ~~**Corregir healthcheck de Portainer**~~ ✅ **Ejecutado ago-2026**: `--no-check-certificate` añadido.
3. **Corregir lógica de verificación en `setup.sh`**:
   - Eliminar la llamada duplicada (línea 352 o 353).
   - Pasar `expected=true` cuando el contenedor fue desplegado por esta instalación; tratar `PORTAINER_ON_HOST=true` como "skip" sin contar en `total`.
4. ~~**Serializar pulls de modelos**~~ ✅ **Ejecutado ago-2026** (variante: se mantiene el paralelismo pero con propagación de fallos — PIDs individuales, `wait` por PID, `return 1` si alguno falla y resumen `N/M fallidos`).
5. **Eliminar código muerto**: borrar `scripts/ollama-entrypoint.sh` o cablearlo de verdad al compose (`entrypoint: ["/bin/bash","/entrypoint.sh"]` + `OLLAMA_MODELS` en `environment:`), teniendo en cuenta que la imagen no trae `curl` (usar `ollama list` como ready-check).

## Prioridad P1 — Seguridad (≈ 2 h)

6. ~~**Bindear puertos a localhost**~~ ✅ **Ejecutado ago-2026**: las 4 publicaciones (9443/11434/3000/8188) bindeadas a `127.0.0.1:`. Falta actualizar `ARCHITECTURE.md:80`.
7. **Montar docker.sock read-only** (`docker-compose.yml:13`): `/var/run/docker.sock:/var/run/docker.sock:ro`; valorar socket-proxy si se expone más allá de localhost.
8. **Generar `WEBUI_SECRET_KEY` automáticamente** en `setup.sh` (fase_stack) cuando se cree `.env`: `WEBUI_SECRET_KEY=$(openssl rand -hex 32)` en lugar de copiar el placeholder; mantener el `warn`.
9. Documentar/mitigar la carrera de primer-registro-admin de Open WebUI (crear admin inmediatamente tras levantar, o `WEBUI_AUTH` + registro cerrado).
10. `chmod 700` al `BACKUP_DIR` en `backup.sh` antes de copiar `.env`.

## Prioridad P2 — Consistencia y docs (≈ 2 h)

11. Unificar lista de modelos en una sola fuente (p.ej. arrays en `lib/docker.sh` consultables por perfil) usada por `setup.sh`, `update.sh` y `.env.example`; eliminar `OLLAMA_MODELS` de `.env.example` o consumirlo realmente.
12. Resincronizar `ARCHITECTURE.md` con el compose: imagen `comfyui-boot:cpu` + `--cpu`, servicio real de screenshot-to-code (host, puerto 7001) o eliminarlo del diagrama; corregir claim de localhost (ver #6).
13. `Makefile`: derivar `SERVICES` del perfil activo (o quitar `comfyui` del default y añadir `make start-full`).
14. `status.sh` y `update.sh`/`docker.sh`: leer puertos desde `.env` / variables detectadas (`${ZEN_OLLAMA_PORT:-11434}`) en vez de hardcodear 11434/3000/8188/9443.
15. `uninstall.sh`: segunda confirmación explícita antes de borrar assets de usuario (`comfyui/output|workflows|models`) y limpiar también `~/.local/bin/opencode` + línea PATH del rc.
16. CI (`test.yml`): completar `bash -n` con los 4 scripts omitidos y añadir un job `docker compose config -q` como smoke test.

## Prioridad P3 — Mejoras estructurales (si se reviva el proyecto)

17. **Perfil GPU condicional**: detección NVIDIA en `detect.sh` + override `docker-compose.gpu.yml` con `reservations.devices [gpu]` para ollama y `yanwk/comfyui-boot:cu126-slim` (el tag `:latest` ya no existe upstream). Sin GPU, ajustar expectativas en README (SDXL en CPU = decenas de minutos/imagen).
18. **Recalibrar límites de RAM** para equipos de 16 GB (ollama 8G, comfyui 6G) o documentar que full profile requiere ≥32 GB; hoy suman 21,25 GB.
19. Soporte multi-distro en `install.sh` (branch por `OS_ID`: apt/dnf/pacman) y evitar `curl | sudo bash` (descargar, verificar checksum, ejecutar).
20. Fijar versiones de imágenes por variable (p.ej. `OLLAMA_VERSION=0.21.x`) en lugar de `:latest` para updates reproducibles; `make update` debería exigir confirmación y usar `--no-force-recreate` salvo cambio real de imagen.

## Criterio de aceptación

- `make backup` produce archives no vacíos verificables.
- Todos los contenedores reportan `healthy` a los 2 min de `make start`.
- `setup.sh` termina con "All N services verified" correcto.
- `ss -tlnp | grep -E '11434|3000|8188|9443'` muestra binds en 127.0.0.1.
- gitleaks sigue limpio tras los cambios.
