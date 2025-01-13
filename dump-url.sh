#!/bin/sh

. ./env.sh

url="${1?Provide a pokeapi URL.}"

# Dump to <dump>/<path>/index.json
id_dir="$(printf '%s' "$url" | sed -r "s|^$ENDPOINT/(.+)/$|$DUMP_DIR/\1|")"
id_filename="$id_dir/index.json"

if [ -e "$id_filename" ]; then
  echo "$id_filename exists, skipping..." >&2
  exit 0
else
  echo "Dumping $url to $id_filename..."
fi

mkdir -p "$id_dir"
curl -sSfL --retry 10 "$url" \
  | sed "s|$ENDPOINT|ENDPOINT|g" \
  | sed "s|https://raw.githubusercontent.com/PokeAPI/cries/main|ENDPOINT/static|g" \
  | sed "s|https://raw.githubusercontent.com/PokeAPI/sprites/master|ENDPOINT/static|g" \
  > "$id_filename"

name=$(jq -r .name "$id_filename")
if [ "$name" != 'null' ]; then
  name_dir="$(dirname "$id_dir")/$name"
  # so we need to take this into account

  # Determine the number of path segments - the name might have a '/'
  # (e.g /api/v2/location/naranja-academy/uva-academy),
  # and so must be handled accordingly.
  segments=$(echo "$name" | tr --complement --delete '/' | wc -c)
  if [ "$segments" -eq 0 ]; then
    ln -s -- "$(basename "$id_dir")" "$name_dir"
  else
    mkdir -p "$(dirname "$name_dir")"
    relative="$(printf '../%.0s' $(seq 1 "$segments"))"
    ln -s -- "$relative$(basename $id_dir)" "$name_dir"
  fi
fi
