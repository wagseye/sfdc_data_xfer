#!/bin/bash

set -e # exit on any errors

if [ -z "$PROJECT_HOME" ]; then
    CWD="$(dirname "$(which "$0")")"
    source $CWD/init.sh
fi

if [ -z "$PROJECT_HOME" ]; then
    echo "init.sh script has not been called" && exit 1;
fi


sf cmdt generate records \
  --csv $STRIPE_PROJ/record_data/data_sources.csv \
  --type-name Data_Source \
  --input-directory=$BASE_HOME/objects/  \
  --output-directory=$STRIPE_HOME/customMetadata
