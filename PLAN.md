# Plan — zen-ai-stack

## Status
- Phase: Implementation
- Version: 0.1.0

## Phases

### Phase 1: Core Infrastructure
- [x] Create directory structure
- [x] docker-compose.yml (4 services: portainer, ollama, open-webui, comfyui)
- [x] .env.example with defaults
- [x] .gitignore
- [ ] GitHub repo created and pushed

### Phase 2: Core Scripts
- [ ] scripts/lib/common.sh (log, die, colors, spinner, progress)
- [ ] scripts/lib/detect.sh (OS, RAM, disk, ports, tools)
- [ ] scripts/lib/install.sh (installers per tool)
- [ ] scripts/lib/docker.sh (Docker helpers, pull models)
- [ ] scripts/setup.sh (main orchestrator)
- [ ] scripts/update.sh (update everything)
- [ ] scripts/uninstall.sh (clean removal)
- [ ] scripts/status.sh (verify all services)
- [ ] scripts/backup.sh (backup configurations)

### Phase 3: Configurations
- [ ] configs/opencode/ollama-provider.tpl
- [ ] configs/vscode/continue-config.tpl
- [ ] configs/open-webui/comfyui-env.tpl

### Phase 4: Profiles
- [ ] bare profile (Docker + Ollama + 1 model)
- [ ] standard profile (default)
- [ ] full profile (+ ComfyUI + CodeNest + screenshot-to-code)
- [ ] --skip-* flags

### Phase 5: Makefile
- [ ] Targets: setup, status, logs, update, stop, start, restart, uninstall, backup, version

### Phase 6: Documentation
- [x] ARCHITECTURE.md
- [x] PLAN.md
- [ ] ROADMAP.md
- [ ] AGENTS.md
- [ ] README.md
- [ ] CHANGELOG.md
- [ ] CONTRIBUTING.md
- [ ] SECURITY.md
- [ ] docs/GUIDE_QUICKSTART.md
- [ ] docs/GUIDE_CODE.md
- [ ] docs/GUIDE_LOGOS.md
- [ ] docs/GUIDE_WEB.md
- [ ] docs/GUIDE_MOBILE.md
- [ ] docs/GUIDE_WRITING.md
- [ ] docs/GUIDE_RAG.md
- [ ] docs/GUIDE_CODENEST.md
- [ ] docs/GUIDE_MAINTENANCE.md
- [ ] docs/GUIDE_DESIGN.md
- [ ] docs/WINDOWS.md
- [ ] docs/PROFILES.md
- [ ] docs/TROUBLESHOOTING.md
- [ ] docs/FAQ.md

### Phase 7: CI and Quality
- [ ] .github/workflows/test.yml (shellcheck)
- [ ] VERSION file
- [ ] LICENSE

## Dependencies
- docker-compose.yml → Phase 1 (no scripts needed)
- scripts/lib/* → Phase 2a (independent)
- scripts/setup.sh → requires all lib/*
- Makefile → requires setup.sh
- Documentation → can run in parallel
