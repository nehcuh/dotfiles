.PHONY: help up down rebuild shell logs clean db all

help: ## Show this help message
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-15s %s\n", $$1, $$2}'

up: ## Start minimal devbox
	docker-compose up -d

down: ## Stop all services
	docker-compose down

down-all: ## Stop with volumes
	docker-compose down -v

rebuild: ## Rebuild images
	docker-compose build --no-cache

shell: ## Enter devbox shell
	docker exec -it devbox zsh

logs: ## View devbox logs
	docker-compose logs -f devbox

db: ## Start with databases (postgres + redis)
	docker-compose -f docker-compose.yml -f docker-compose.db.yml up -d

all: ## Start with all services
	docker-compose -f docker-compose.yml -f docker-compose.db.yml -f docker-compose.extra.yml up -d

ps: ## Show running containers
	docker-compose ps

clean: ## Remove containers and volumes
	docker-compose down -v
	docker system prune -f

ssh: ## Enable SSH and restart
	docker-compose stop
	docker-compose up -d
	@echo "SSH enabled on port 2222"
	@echo "Connect with: ssh $${USER}@localhost -p 2222"
