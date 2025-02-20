#!/bin/bash

set -e # exit on any errors

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

sf cmdt generate records \
  --csv $STRIPE_PROJ/record_data/object_fields.csv \
  --type-name Object_Field \
  --input-directory=$BASE_HOME/objects/  \
  --output-directory=$STRIPE_HOME/customMetadata
