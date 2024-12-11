
.PHONY: all pokeapi-up pokeapi-down dump image run

all: pokeapi-up dump image

pokeapi-up:
	make --directory=pokeapi docker-setup

pokeapi-down:
	make --directory=pokeapi docker-down

dump:
	./scrape.sh

image:
	docker build --tag alexandrecarlton/pokeapi-dump .

run: image
	docker run --rm -it -p 8080:80 -e ENDPOINT=http://localhost:8080 alexandrecarlton/pokeapi-dump
