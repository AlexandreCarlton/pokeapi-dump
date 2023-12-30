#!/bin/sh -e

. ./env.sh

LIMIT=10000

# See https://pokeapi.co/docs/v2 for a complete list of resources that can be downloaded.
NAMES='
  berry
  berry-firmness
  berry-flavor
  contest-type
  contest-effect
  super-contest-effect
  encounter-method
  encounter-condition
  encounter-condition-value
  evolution-chain
  evolution-trigger
  generation
  pokedex
  version
  version-group
  item
  item-attribute
  item-category
  item-fling-effect
  item-pocket
  location
  location-area
  pal-park-area
  region
  machine
  move
  move-ailment
  move-battle-style
  move-category
  move-damage-class
  move-learn-method
  move-target
  ability
  characteristic
  egg-group
  gender
  growth-rate
  nature
  pokeathlon-stat
  pokemon
  pokemon-location-area
  pokemon-color
  pokemon-habitat
  pokemon-shape
  pokemon-species
  stat
  type
  language
'

mkdir -p $DUMP_DIR

for name in $NAMES; do
  mkdir -p "$DUMP_DIR/$name"
  curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
    | jq -r .results[].url \
    | parallel -j 8 ./dump-url.sh
done
