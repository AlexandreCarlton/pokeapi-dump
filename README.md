# PokeAPI dump

![Build](https://github.com/alexandrecarlton/pokeapi-dump/actions/workflows/build-and-push.yml/badge.svg)

A dump of the `pokeapi.co` packaged in a neat NGINX server. Only look-up by
ID or namess are supported - no pagination is offered.

To spin this up, run:

```bash
docker run --rm -it \
  -p 8080:80 \
  -e ENDPOINT=http://localhost:8080 \
  docker.io/alexandrecarlton/pokeapi-dump:latest
```

## Motivation

The existing endpoint contains a wealth of data but it is locked behind an
remote endpoint, introducing a non-negligible latency cost.

Furthermore, spinning this up locally requires multiple services and a python installation.

If we are only interested in look-up by ID/name, we can build something much simpler
and faster.

## How does this work?

We:

 - fire up a local instance.
 - trawl through the endpoints, dumping the contents into `.json` files.
 - package this into an NGINX server which can serve this data with ease.

## Limitations

 - Pagination not supported (e.g. `/pokemon?limit=10`)
 - Path `/pokemon/{id or name}/encounters` not supported.
 - Look-up by name for data that share the same ID may return different data to
   the original.

# Running

## Dump

### Requirements

 - `curl`
 - `docker-compose`
 - `parallel`
 - `jq`

### Running

Run:

```sh
# Spin up local instance of pokapi
make pokeapi-up

# Produce dump of JSON files
make dump
```

The contents of the dump will be stored in `./dump`.

## Server

### Requirements

 - `docker`

### Running

```bash
docker build -t pokeapi-dump .

docker run --rm -it \
  -p 8080:80 \
  -e ENDPOINT=http://localhost:8080 \
  pokeapi-dump
```

# Results

We compare the local implementation (first) with our NGINX server (second) to
get a rough estimate of the gains achieved:

```
❯ hyperfine --runs 50 --warmup 3 "curl -L http://localhost:80/api/v2/pokemon/1/" "curl -L http://localhost:8081/pokemon/1/"
Benchmark 1: curl -L http://localhost:80/api/v2/pokemon/1/
  Time (mean ± σ):     217.8 ms ±  14.2 ms    [User: 1.9 ms, System: 2.1 ms]
  Range (min … max):   207.7 ms … 265.2 ms    50 runs

Benchmark 2: curl -L http://localhost:8081/pokemon/1/
  Time (mean ± σ):       4.2 ms ±   0.6 ms    [User: 2.2 ms, System: 2.0 ms]
  Range (min … max):     3.1 ms …   5.3 ms    50 runs

Summary
  curl -L http://localhost:8081/pokemon/1/ ran
   52.25 ± 7.91 times faster than curl -L http://localhost:80/api/v2/pokemon/1/
```

Of course, this comes at the cost of reduced functionality - but if all that is
needed is to look up pokemon data by id, this is a good place to start.
