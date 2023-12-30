#!/bin/sh

# We exchange a smidge of start-up time (rather than substituting out environment variables at request time)
# for blazing fast latencies - anecdotally, this halves the latency compared to having this in out config:
#
#   location ... {
#     sub_filter 'ENDPOINT' '$ENDPOINT';
#     sub_filter_once off;
#     sub_filter_types 'application/json';
#   }

find /usr/share/nginx/html \
  -type f \
  -name '*.json' \
  -print0 \
  | xargs -0 \
    sed -i "s|ENDPOINT|$ENDPOINT|g"
