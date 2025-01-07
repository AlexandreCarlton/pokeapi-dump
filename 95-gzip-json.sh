#!/bin/sh

# We create gzipped equivalents of our JSON files at start-up to avoid the need for on-the-fly compression.
#
# This must be done at start-up (rather than build) as the original files are updated using environment variables
# (see ./90-substitute-endpoint.sh).

find /usr/share/nginx/html \
  -type f \
  -name '*.json' \
  -print0 \
  | xargs -0 \
    gzip --keep

