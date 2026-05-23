.PHONY: setup status logs update stop start restart uninstall backup version help

setup:
	./scripts/setup.sh

status:
	./scripts/status.sh

logs:
	docker compose --profile standard logs -f

update:
	./scripts/update.sh

stop:
	docker compose --profile standard down

start:
	docker compose --profile standard up -d

restart: stop start

uninstall:
	./scripts/uninstall.sh

backup:
	./scripts/backup.sh

version:
	@cat VERSION

help:
	@echo "zen-ai-stack commands:"
	@echo "  make setup      — Install Stack"
	@echo "  make status     — Check status of all services"
	@echo "  make logs       — View live logs"
	@echo "  make update     — Pull latest images + models"
	@echo "  make stop       — Stop all services"
	@echo "  make start      — Start all services"
	@echo "  make restart    — Restart all services"
	@echo "  make uninstall  — Remove everything"
	@echo "  make backup     — Backup configurations"
	@echo "  make version    — Show version"
