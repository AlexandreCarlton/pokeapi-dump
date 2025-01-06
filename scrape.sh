#!/bin/sh -e

# Scrapes a PokeAPI server located at $ENDPOINT, storing the results in $DUMP_DIR.
#
# It does this by:
#  - listing the top-level resources (e.g. berry, move, pokemon).
#  - listing the items underneath each resource (e.g. berry/1, berry/2).
#  - downloading each item.

. ./env.sh

LIMIT=10000

mkdir -p $DUMP_DIR

# The overall index on '/' indicates what resources are available (pokemon, item, etc.)
if [ -e "$DUMP_DIR/index.json" ]; then
  echo "$DUMP_DIR/index.json exists, skipping..." >&2
else
  echo "Dumping $ENDPOINT/index.json to $DUMP_DIR/index.json..."
  curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
    | sed "s|$ENDPOINT|ENDPOINT|g" \
    > "$DUMP_DIR/index.json"
fi

# Pull own each each resource (pokemon, item, etc.) to get a list of all
# things in that resource (pokemon/1, pokemon/2) and dump it to a file.
jq -r 'keys[]' dump/index.json | while read -r name; do
  if [ -e "$DUMP_DIR/$name.json" ]; then
    echo "$DUMP_DIR/$name.json exists, skipping..." >&2
  else
    echo "Dumping $ENDPOINT/$name?limit=$LIMIT to $DUMP_DIR/$name.json..."
    curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
      | sed "s|$ENDPOINT|ENDPOINT|g" \
      > "$DUMP_DIR/$name.json"
  fi

  mkdir -p "$DUMP_DIR/$name"
  jq -r .results[].url "$DUMP_DIR/$name.json" \
    | sed "s|ENDPOINT|$ENDPOINT|g" \
    | parallel -j "$(nproc)" ./dump-url.sh
done

# Copy across static files (as otherwise we point to files on raw.githubusercontent.com, which might not match).
rm -rf dump/static
mkdir -p dump/static
echo "Dumping pokeapi/data/v2/cries/cries to dump/static..."
cp -r pokeapi/data/v2/cries/cries dump/static
echo "Dumping pokeapi/data/v2/sprites/sprites to dump/static..."
cp -r pokeapi/data/v2/sprites/sprites dump/static

echo "Finished dump."

# It is not impossible something goes wrong when dumping - in such cases we get an empty file.
# We print this out to better debug this.
echo "Empty files found:"
find dump -type f -empty -print
