#!/bin/sh

# Contains constants shared across multiple scripts.

# Where the dumps should be stored.
DUMP_DIR=dump
# Where API files should stored.
API_DUMP_DIR=$DUMP_DIR/api/v2
# Where static resources should be stored.
STATIC_DUMP_DIR=$DUMP_DIR/static

# This must match the base endpoint returned in the json responses to facilitate modifying it at runtime.
ENDPOINT=http://localhost/api/v2
