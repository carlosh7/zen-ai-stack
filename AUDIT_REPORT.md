# AUDIT_REPORT.md — zen-ai-stack

Fecha: 2026-08-21 · Auditoría estática (sin levantar servicios) · 18 commits · v0.1.0 · Estado: **absorbido por CodeNest (EOL, read-only)**

## Score global: 63/100

| Dimensión | Peso | Puntos | Justificación breve |
|---|---|---|---|
| Avance vs PLAN | 20 | 15 | Todas las fases declaradas ✅ existen y son coherentes; pero el repo está absorbido/EOL y hay piezas "documentadas" inexistentes |
| Calidad scripts/configs | 15 | 11 | `set -euo pipefail` uniforme, libs modulares, `bash -n` limpio en los 14 scripts; código muerto y hardcoding de puertos restan |
| Bugs | 15 | 7 | Bug crítico en backups + lógica de verificación invertida + healthcheck roto |
| Seguridad | 20 | 11 | gitleaks limpio, sin secretos reales; pero puertos en 0.0.0.0, docker.sock rw, servicios sin auth |
| Eficiencia recursos | 10 | 5 | Sin GPU (SDXL en CPU inviable), límites de RAM que sobre-comprometen un portátil de 16 GB |
| Versiones imágenes | 5 | 4 | `portainer-ce:lts` y `comfyui-boot:cpu` vigentes (ago-2026); `ollama`/`open-webui` en `:latest` sin fijar |
| Diseño/orquestación | 15 | 10 | Buena separación lib/, perfiles, bundle offline; drift docs↔compose, entrypoint huérfano, listas de modelos divergentes |

---

## 1) Inventario de servicios AI orquestados

`docker-compose.yml` orquesta **4 servicios** en red bridge `zen-ai-stack`:

| Servicio | Imagen | Puerto host→contenedor | Rol |
|---|---|---|---|
| `portainer` | `portainer/portainer-ce:lts` | 9443→9443 | Gestión Docker (UI) |
| `ollama` | `ollama/ollama:latest` | 11434→11434 | Motor LLM local |
| `open-webui` | `ghcr.io/open-webui/open-webui:latest` | 3000→8080 | Chat unificado + generación de imágenes |
| `comfyui` | `yanwk/comfyui-boot:cpu` (`CLI_ARGS=--cpu`) | 8188→8188 | Generación de imágenes (SDXL + LoRAs) |

Modelos referenciados (pull vía host/scripts, no entrypoint): `qwen2.5-coder:7b`, `llama3.2-vision:11b`, `llama3.2:3b`, `nomic-embed-text`, `deepseek-coder-v2:16b`, `qwen2.5:14b`. Herramientas de host instaladas por `setup.sh`: OpenCode (+wrapper), VS Code+Continue, Antigravity, VTracer, Inkscape, CodeNest, screenshot-to-code (clonado en `tools/`, **no** es servicio).

## 2) Avance vs README/PLAN y completitud

- `PLAN.md` declara **100%** (fases 1–7 ✅). Verificado: los entregables existen (scripts, configs, CI shellcheck, docs).
- **README.md actual**: el proyecto fue **absorbido por CodeNest** y es histórico/read-only. El desarrollo activo está en otro repo.
- **Completitud funcional real: ~85%.**
- **Caja vacía (promesas sin entrega)**:
  - `ARCHITECTURE.md:57` documenta flujo `screenshot-to-code (:5173)` como servicio del stack → **no existe en compose**; se clona en host con `BACKEND_PORT=7001` (además, puerto distinto al documentado).
  - `ARCHITECTURE.md:40` declara imagen `comfyui-boot:latest` con `--force-fp16 --lowvram-mode` → el compose usa `:cpu` con `--cpu`. Drift total.
  - Soporte GPU: implícito por los casos de uso (SDXL, visión) pero **ausente por diseño** (ver §6).
  - `.env.example:25` define `OLLAMA_MODELS` que ningún script consume (`setup.sh:170-177` hardcodea listas por perfil).

## 3) Calidad de scripts/configs

Positivo:
- Los 14 scripts pasan `bash -n`; estilo consistente (`set -euo pipefail`, funciones snake_case, colores/log centralizados en `lib/common.sh`).
- Idempotencia razonable (checks de "ya instalado", detección de Ollama/Portainer existentes, reasignación de puertos ocupados en `detect.sh:54-79`).
- Bundle offline bien pensado (export/import imágenes+modelos+LoRAs con manifest.json).
- CI con shellcheck (`test.yml`) aunque la cobertura de `bash -n` omite `opencode.sh`, `export-bundle.sh`, `import-bundle.sh`, `lib/bundle.sh`.

Negativo:
- Código muerto: `scripts/ollama-entrypoint.sh` no lo referencia el compose (no hay `entrypoint:` ni se pasa `OLLAMA_MODELS` al contenedor); además usa `curl`, que el propio commit `b2be656` admite que no existe en la imagen de ollama.
- Hardcoding de puertos/nombres que anula el auto-detect: `status.sh:61-74`, `docker.sh:39,46,55,83` (fija `localhost:11434` y `zen-ollama`), `update.sh:27`.
- `install.sh:26` asume `apt` exclusivamente; `detect_os` captura `OS_ID` pero nunca se usa para elegir gestor de paquetes (roto en Fedora/Arch).
- `install.sh:14` patrón `curl | sudo bash`; `install.sh:15` usa `$USER` sin fallback bajo `set -u`.
- `status.sh:26,36`: `head -c 60` puede cortar bytes UTF-8 del emoji.

## 4) Bugs (archivo:línea)

1. **CRÍTICO — Backups vacíos silenciosos**: `scripts/backup.sh:15,21,27` montan `-v ollama_data:/data`, `-v open-webui_data...`, `-v portainer_data...`, pero compose crea los volúmenes **con prefijo de proyecto**: `zen-ai-stack_ollama_data` etc. Docker crea volúmenes nuevos vacíos y archiva nada, reportando éxito. (`bundle.sh:57` sí usa el nombre correcto — la inconsistencia lo confirma.)
2. **Verificación invertida/duplicada**: `scripts/setup.sh:352-353` llama dos veces a `verify_service` para Portainer pasando `$PORTAINER_ON_HOST` como `expected`. Cuando es `false` (el contenedor SÍ se despliega) la verificación se salta pero igual incrementa `total` (líneas 337-340) → `ok_count == total` es imposible y siempre muestra el warn "N/M services verified".
3. **Healthcheck Portainer roto**: `docker-compose.yml:16` — `wget -qO- https://localhost:9443/api/status` contra certificado self-signed sin `--no-check-certificate` → TLS verification falla → contenedor marcado `unhealthy` permanentemente.
4. **Pull paralelo que oculta fallos**: `scripts/lib/docker.sh:104-112` lanza todos los `pull_model &` en background (varios GB cada uno); `wait` sin argumentos devuelve 0 aunque fallen los jobs → "All models downloaded" es éxito falso; satura ancho de banda/disco.
5. **Puertos fijos tras auto-detección**: si `detect_ports_and_assign` reasigna (p.ej. 11435), `wait_for_ollama`/`pull_model` siguen sondeando `localhost:11434` (`docker.sh:46,55`) y `status.sh:61-74` reporta los puertos default → resultados erróneos.
6. **`make start` inconsistente**: `Makefile:3` incluye `comfyui` en `SERVICES`, pero `setup.sh` solo lo levanta en perfil `full` → `make start/logs/down` operan un servicio que puede no existir en despliegues bare/standard.
7. **`uninstall.sh:42`** hace `rm -rf` del repo (incluye assets bind-mounted del usuario en `comfyui/output|workflows|models`) tras una única confirmación genérica; no elimina el wrapper `~/.local/bin/opencode` ni la línea de PATH añadida al rc.
8. **`update.sh:27`** lista por defecto de 4 modelos que ignora los del perfil full (`deepseek-coder-v2:16b`, `qwen2.5:14b`) → post-update quedan desactualizados/no reinstalados.
9. Menor: `detect.sh:68` grep por substring del puerto puede dar falso positivo; `compose_up` (`docker.sh:12`) cambia el cwd permanente del proceso setup.

## 5) Seguridad

- **gitleaks: LIMPIO** — 18 commits escaneados, 0 fugas (`/tmp/opencode/gitleaks-zas.json` = `[]`). No hay secretos reales en el repo.
- **Puertos en 0.0.0.0**: todas las publicaciones `${HOST_PORT_X:-default}:container` bindean a todas las interfaces. `ARCHITECTURE.md:80` afirma "All services are accessible only on localhost by default" → **FALSO**. Debería ser `"127.0.0.1:${PORT}:..."`.
- **docker.sock read-write**: `docker-compose.yml:13` monta `/var/run/docker.sock` sin `:ro` → Portainer comprometido = root en el host (aceptable para su función, mitigable con socket proxy o al menos `:ro`).
- **Servicios sin auth expuestos a LAN**: ComfyUI y la API de Ollama no tienen autenticación; en LAN cualquiera puede generar imágenes o usar/infectar el LLM. Además Open WebUI en 0.0.0.0 con primer-registro=admin introduce carrera de toma de control admin.
- **Secreto placeholder**: `setup.sh:106` copia `.env.example` tal cual; `WEBUI_SECRET_KEY=cambia-este-valor-por-uno-seguro` queda activo si el usuario no edita (solo recibe un `warn` en `setup.sh:108`). Mejor: generarlo aleatorio automáticamente (`openssl rand -hex 32`).
- **Instaladores**: `curl -fsSL https://get.docker.com | sudo bash` (`install.sh:14`) — patrón piping-to-shell a root.
- `backup.sh` copia `.env` (con secretos) a `~/zen-ai-stack-backups/...` sin restringir permisos del directorio (sin `chmod 700`).

## 6) Eficiencia / recursos

- **Sin GPU en todo el stack**: ollama sin `deploy.resources.reservations.devices [gpu]`, ComfyUI con imagen `:cpu` + `--cpu`. En CPU, una imagen SDXL tarda decenas de minutos (una SD 1.5 512² ya son ~5–10 min): el caso de uso estrella del stack (diseño/logos) es prácticamente inusable sin GPU. Al menos falta perfil GPU condicional.
- **Sobre-compromiso de RAM**: límites 12G (ollama) + 8G (comfyui) + 1G (webui) + 256M (portainer) = **21,25 GB**, sobre equipos objetivo de 16–32 GB (AGENTS.md). En un portátil de 16 GB, con keep_alive por defecto de Ollama cargando varios modelos, hay riesgo de swap/OOM.
- Límite de 12 G para ollama es justo para `deepseek-coder-v2:16b` q4 (~9–10 GB) + contexto.
- Pull paralelo de ~30 GB de modelos (bug #4) satura disco/red.

## 7) Versiones de imágenes (ago-2026)

| Imagen usada | Estado actual | Veredicto |
|---|---|---|
| `portainer/portainer-ce:lts` | tag `lts` activo (2.39.x LTS, push hace días; STS 2.44) | ✔ Correcto y mantenible |
| `ollama/ollama:latest` | serie actual ~0.18–0.21 | ⚠ Flotante sin pin; actualizar = riesgo de breaking changes silenciosos |
| `ghcr.io/open-webui/open-webui:latest` | ~0.9.x | ⚠ Ídem; muy alta cadencia de releases |
| `yanwk/comfyui-boot:cpu` | tag vigente y actualizado (cpu-20260817); `:latest` fue eliminado a mediados de 2026 | ✔ Tag correcto; **`ARCHITECTURE.md:40` aún cita `:latest` (obsoleto)** |

## 8) Diseño / orquestación

- Arquitectura en capas clara (orquestación/procesamiento/imagen/control), red dedicada, healthchecks y memory limits en los 4 servicios, volúmenes nombrados para estado, bind mounts para assets de ComfyUI.
- Librerías bash modulares (`common/detect/install/docker/bundle`) con buena separación; perfiles bare/standard/full; modo offline con manifest.
- Debilidades: drift sistemático docs↔código (imagen/flags/puertos de ComfyUI, servicio screenshot-to-code fantasma, claim de localhost), entrypoint huérfano, tres listas distintas de modelos (.env.example / setup / update), `Makefile` desalineado con los perfiles, y el propio repo ya absorbido por CodeNest (mantener este fork tiene poco valor salvo histórico).

## 9) Runtime viable

- `docker compose config` → **✓ válido** (exit 0, sin warnings bloqueantes; no se levantó ningún servicio).
- `bash -n` sobre los 14 scripts → **✓** todos OK.
- shellcheck: **no disponible localmente** (CI lo ejecuta; PLAN reclama 0 errores). No hay Python en el repo (solo heredocs inline) → `ruff/bandit/pip-audit` **N/A**.
- Verificación de sintaxis YAML/Makefile: OK. Conclusión: **el stack es ejecutable tal cual** (CPU-only), con los bugs funcionales descritos (backups vacíos, verificación engañosa, healthcheck unhealthy) que no impiden arrancar pero sí degradan operación.

---

## Conclusión

Stack local AI bien estructurado y arrancable, con documentación extensa, pero en fin de vida (absorbido por CodeNest). Sus problemas principales son de **operación y confianza**: backups que no respaldan, verificaciones que mienten, exposición de red mayor a la documentada y ausencia total de GPU para su propio caso de uso principal. Score: **63/100** — apropiado como histórico/referencia; no recomendaría desplegarlo en producción sin el plan de acción adjunto.
