
build : 
	docker compose -f ./srcs/docker-compose.yml up --build 
down : 
	docker compose -f ./srcs/docker-compose.yml down -v

start : 
	docker compose -f ./srcs/docker-compose.yml start

stop : 
	docker compose -f ./srcs/docker-compose.yml stop
clean: down
	docker system prune -af --volumes 

restart: stop build

.PHONY: up rebuild down start stop