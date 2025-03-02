
.PHONY: all pokeapi-up pokeapi-down dump image run

all: pokeapi-up dump image

pokeapi-up:
	# sed -ri 's/(.*)limit_conn (.*)/\1# limit_conn \2/' pokeapi/Resources/nginx/nginx.conf
	make --directory=pokeapi docker-setup

pokeapi-down:
	make --directory=pokeapi docker-down

dump:
	uv run -- scrapy crawl pokeapi -L INFO
	cp -r pokeapi/data/v2/cries/cries dump/static
	cp -r pokeapi/data/v2/sprites/sprites dump/static

image:
	docker build --tag alexandrecarlton/pokeapi-dump .

run: image
	docker run --rm -it -p 8081:80 -e ENDPOINT=http://localhost:8081 alexandrecarlton/pokeapi-dump
