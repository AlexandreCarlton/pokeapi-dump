#!/bin/sh -e

# Scrapes a PokeAPI server located at $ENDPOINT, storing the results in $DUMP_DIR.
#
# It does this by:
#  - listing the top-level resources (e.g. berry, move, pokemon).
#  - listing the items underneath each resource (e.g. berry/1, berry/2).
#  - downloading each item.

. ./env.sh

LIMIT=10000

mkdir -p $API_DUMP_DIR
mkdir -p $STATIC_DUMP_DIR

# The overall index on '/' indicates what resources are available (pokemon, item, etc.)
if [ -e "$API_DUMP_DIR/index.json" ]; then
  echo "$API_DUMP_DIR/index.json exists, skipping..." >&2
else
  echo "Dumping $ENDPOINT/index.json to $API_DUMP_DIR/index.json..."
  curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
    | sed "s|$ENDPOINT|ENDPOINT|g" \
    > "$API_DUMP_DIR/index.json"
fi

# Pull own each each resource (pokemon, item, etc.) to get a list of all
# things in that resource (pokemon/1, pokemon/2) and dump it to a file.
jq -r 'keys[]' $API_DUMP_DIR/index.json | while read -r name; do
  if [ -e "$API_DUMP_DIR/$name.json" ]; then
    echo "$API_DUMP_DIR/$name.json exists, skipping..." >&2
  else
    echo "Dumping $ENDPOINT/$name?limit=$LIMIT to $API_DUMP_DIR/$name.json..."
    curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
      | sed "s|$ENDPOINT|ENDPOINT|g" \
      > "$API_DUMP_DIR/$name.json"
  fi

  mkdir -p "$API_DUMP_DIR/$name"
  jq -r .results[].url "$API_DUMP_DIR/$name.json" \
    | sed "s|ENDPOINT|$ENDPOINT|g" \
    | parallel -j "$(nproc)" ./dump-url.sh
done

# TODO: Not all resources have ids - for example, /pokemon/1/encounters
# We thus scan for these (there is only one type, mercifully) and dump them.

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
