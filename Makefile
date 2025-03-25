.PHONY: up down clean

up:
	docker-compose up

down:
	docker-compose down

clean: down
	docker-compose rm -f

run: up
	bundle install
	foreman s
