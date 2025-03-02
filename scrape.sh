#!/bin/sh -e

# Scrapes a PokeAPI server located at $ENDPOINT, storing the results in $DUMP_DIR.
#
# It does this by:
#  - listing the top-level resources (e.g. berry, move, pokemon).
#  - listing the items underneath each resource (e.g. berry/1, berry/2).
#  - downloading each item.

. ./env.sh

LIMIT=10000

mkdir -p $DUMP_DIR/api/v2
mkdir -p $STATIC_DUMP_DIR

# The overall index on '/' indicates what resources are available (pokemon, item, etc.)
if [ -e $DUMP_DIR/api/v2/index.json ]; then
  echo "$DUMP_DIR/api/v2/index.json exists, skipping..." >&2
else
  echo "Dumping $ENDPOINT/api/v2/index.json to $DUMP_DIR/api/v2/index.json..."
  curl -sSfL "$ENDPOINT/api/v2/" \
    | sed "s|$ENDPOINT|ENDPOINT|g" \
    > "$DUMP_DIR/api/v2/index.json"
fi

# Pull own each each resource (pokemon, item, etc.) to get a list of all
# things in that resource (pokemon/1, pokemon/2) and dump it to a file.
jq -r 'keys[]' $DUMP_DIR/api/v2/index.json | while read -r name; do
  if [ -e "$DUMP_DIR/api/v2/$name/index.json" ]; then
    echo "$DUMP_DIR/api/v2/$name/index.json exists, skipping..." >&2
  else
    echo "Dumping $ENDPOINT/api/v2/$name/?limit=$LIMIT to $DUMP_DIR/api/v2/$name/index.json..."
    mkdir -p "$DUMP_DIR/api/v2/$name"
    curl -sSfL "$ENDPOINT/api/v2/$name/?limit=$LIMIT" \
      | sed "s|$ENDPOINT|ENDPOINT|g" \
      > "$DUMP_DIR/api/v2/$name/index.json"
  fi

  jq -r .results[].url "$DUMP_DIR/api/v2/$name/index.json" \
    | sed "s|ENDPOINT|$ENDPOINT|g" \
    | parallel -j "$(nproc)" ./dump-url.sh
done

# Not all resources have ids - for example, /pokemon/1/encounters
# We thus scan for these (there is only one type, mercifully) and dump them.
find $DUMP_DIR/api/v2/pokemon \
  -type f \
  -name 'index.json'
  | jq -r .location_area_encounters \
  | sed "s|ENDPOINT|$ENDPOINT|g" \
  | parallel -j "$(nproc)" ./dump-url.sh

# Copy across static files (as otherwise we point to files on raw.githubusercontent.com, which might not match).
rm -rf $STATIC_DUMP_DIR
mkdir -p $STATIC_DUMP_DIR
echo "Dumping pokeapi/data/v2/cries/cries to $STATIC_DUMP_DIR..."
cp -r pokeapi/data/v2/cries/cries $STATIC_DUMP_DIR
echo "Dumping pokeapi/data/v2/sprites/sprites to $STATIC_DUMP_DIR..."
cp -r pokeapi/data/v2/sprites/sprites $STATIC_DUMP_DIR

echo "Finished dump."

# It is not impossible something goes wrong when dumping - in such cases we get an empty file.
# We print this out to better debug this.
echo "Empty files found:"
find $DUMP_DIR -type f -empty -print
