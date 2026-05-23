.PHONY: setup status logs update stop start restart uninstall backup version help export-bundle import-bundle manual

SERVICES = ollama open-webui portainer comfyui

setup:
	./scripts/setup.sh

status:
	./scripts/status.sh

logs:
	docker compose logs -f $(SERVICES)

update:
	./scripts/update.sh

stop:
	docker compose down $(SERVICES)

start:
	docker compose up -d $(SERVICES)

restart: stop start

uninstall:
	./scripts/uninstall.sh

backup:
	./scripts/backup.sh

export-bundle:
	./scripts/export-bundle.sh

import-bundle:
	./scripts/import-bundle.sh

manual:
	@echo "Create a manual from Markdown: pandoc file.md -o file.pdf"
	@echo "Create a presentation: marp file.md --pdf -o file.pdf"
	@echo "See docs/GUIDE_PRESENTATIONS.md for details"

version:
	@cat VERSION

help:
	@echo "zen-ai-stack commands:"
	@echo "  make setup          — Install Stack"
	@echo "  make status         — Check status of all services"
	@echo "  make logs           — View live logs"
	@echo "  make update         — Pull latest images + models"
	@echo "  make stop           — Stop all services"
	@echo "  make start          — Start all services"
	@echo "  make restart        — Restart all services"
	@echo "  make uninstall      — Remove everything"
	@echo "  make backup         — Backup configurations"
	@echo "  make export-bundle  — Create offline installation bundle"
	@echo "  make import-bundle  — Restore from offline bundle"
	@echo "  make version        — Show version"
