
.PHONY: all pokeapi-up pokeapi-down dump image

all: pokeapi-up dump image

pokeapi-up:
	make --directory=pokeapi docker-setup

pokeapi-down:
	make --directory=pokeapi docker-down

dump:
	./scrape.sh

image:
	docker build --tag alexandrecarlton/pokeapi-dump .
