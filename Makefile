.PHONY: up down clean setup rebuild run run-fresh nginx-reload nginx-logs nginx-test logs psql console restart

USER ?= $(shell whoami)
APP_CONTAINER = mcp_app_$(USER)
DB_CONTAINER = mcp_app_db_$(USER)
NGINX_CONTAINER = mcp_nginx_$(USER)

up:
	docker compose up -d

down:
	docker compose down

clean: down
	docker compose rm -f
	docker rm -f $(APP_CONTAINER) $(DB_CONTAINER) $(NGINX_CONTAINER) 2>/dev/null || true

setup: up
	docker compose exec app bin/setup --skip-server

rebuild: clean
	docker compose build --no-cache --pull
	docker compose up -d

run-fresh: rebuild
	docker compose exec app bin/setup --skip-server
	docker compose exec app foreman start

run: clean up
	docker compose exec app bin/setup --skip-server
	docker compose exec app foreman start

restart:
	docker compose restart

console:
	docker compose exec app bin/rails console

psql:
	docker compose exec app psql -h db -U mcp -d my_mcp_app_development

logs:
	docker compose logs -f app db nginx

nginx-reload:
	docker compose exec nginx nginx -s reload

nginx-logs:
	docker compose logs -f nginx

nginx-test:
	curl -v http://localhost:8080/up
	curl -v http://localhost:8080/mcp/up
