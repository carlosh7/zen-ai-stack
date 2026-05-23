# AGENTS.md — Guide for AI Agents

This document defines how AI agents (OpenCode, Claude, Cursor, etc.) should work on this project.

## Project Context

**zen-ai-stack** is a local AI stack for coding, designing, and creating content. It runs 100% offline on Linux or Windows (WSL2). Designed for laptops with 16-32 GB RAM.

## Critical Files

| File | Purpose |
|---|---|
| `docker-compose.yml` | Service orchestration |
| `scripts/setup.sh` | Main installer |
| `scripts/lib/common.sh` | Shared functions |
| `scripts/lib/detect.sh` | OS/hardware detection |
| `.env.example` | Environment template |
| `PLAN.md` | Current phase and progress |
| `ARCHITECTURE.md` | Component connections |

## Rules

1. **READ FIRST**: Before modifying any file, read PLAN.md, ARCHITECTURE.md, and the target file completely
2. **Non-destructive**: Never replace existing configs without .bak backup
3. **Bilingual**: Documentation in English and Spanish
4. **Idempotent**: Scripts must produce same result when run N times
5. **Bash 4.0+**: All scripts in bash, compatible with bash 4.0+
6. **No superfluous comments** — code should be self-explanatory

## Code Conventions

### Bash
```bash
# 1. set -euo pipefail at script start
# 2. Descriptive snake_case function names
# 3. Local variables with local keyword
# 4. Colors defined in common.sh
install_docker() {
    local version
    version=$(docker --version 2>/dev/null)
}
```

### YAML
```yaml
# 1. Descriptive service names
# 2. Healthchecks on all services
# 3. Memory limits
# 4. Named volumes for persistence
```

### Markdown
```markdown
# Title (H1)
## Section (H2)
### Subsection (H3)
- Lists with dashes
- Code in backticks
[Links](url)
```

## Pre-commit Checklist

- [ ] `shellcheck scripts/*.sh` — No errors
- [ ] `bash -n scripts/setup.sh` — Valid syntax
- [ ] Documentation updated
- [ ] No hardcoded secrets
- [ ] PLAN.md updated if phase changed

## Workflow

```
1. Read PLAN.md → Understand current phase
2. Read ARCHITECTURE.md → Understand context
3. Modify files
4. Run shellcheck
5. Update PLAN.md if needed
```
