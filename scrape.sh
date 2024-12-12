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

if [ -e "$DUMP_DIR/index.json" ]; then
  echo "$DUMP_DIR/index.json exists, skipping..." >&2
else
  echo "Dumping $ENDPOINT/index.json to $DUMP_DIR/index.json..."
  curl -sSfL "$ENDPOINT/$name?limit=$LIMIT" \
    | sed "s|$ENDPOINT|ENDPOINT|g" \
    > "$DUMP_DIR/index.json"
fi

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
