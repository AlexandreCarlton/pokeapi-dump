#!/bin/sh

. ./env.sh

url="${1?Provide a pokeapi URL.}"

# Dump to <dump>/<type>/<num>.json
id_filename="$(printf '%s' "$url" | sed -r "s|^$ENDPOINT/([a-z-]+/[0-9-]+)/$|$DUMP_DIR/\1.json|")"
if [ -e "$id_filename" ]; then
  echo "$id_filename exists, skipping..." >&2
  exit 0
else
  echo "Dumping $url to $id_filename..."
fi

curl -sSfL --retry 10 "$url" \
  | sed "s|$ENDPOINT|ENDPOINT|g" \
  | sed "s|https://raw.githubusercontent.com/PokeAPI/cries/master|ENDPOINT/static|g" \
  | sed "s|https://raw.githubusercontent.com/PokeAPI/sprites/master|ENDPOINT/static|g" \
  > "$id_filename"

name=$(jq -r .name "$id_filename")
if [ "$name" != 'null' ]; then
  # The name might have a '/', so we need to take this into account
  name_filename="$(dirname "$id_filename")/$name.json"
  mkdir -p "$(dirname "$name_filename")"
  # We may occasionally find data with the same name - so we just force overwrite it as a mitigation strategy.
  # <dump>/<type>/<name>.json -> <id>.json
  ln -sf -- "$(basename "$id_filename")" "$name_filename"
fi
