#!/bin/bash

# Find the project home by searching for the sfdx-project.json file
CURRENT_DIR="$(pwd)"
while [ "$CURRENT_DIR" != "/" ]; do
    # Check if the target file exists in the current directory
    if [ -e "$CURRENT_DIR/sfdx-project.json" ]; then
        PROJECT_HOME=$(realpath --relative-to=. $CURRENT_DIR)
        break
    fi
    # Move up one directory
    CURRENT_DIR=$(dirname "$CURRENT_DIR")
done

if [ -z ${PROJECT_HOME+x} ]; then
    echo "Did not find a project home folder. Are you within an SFDX project?"
    exit 1
fi

BASE_PROJ=$PROJECT_HOME/data-xfer
BASE_HOME=$BASE_PROJ/main/default

STRIPE_PROJ=$PROJECT_HOME/stripe-service
STRIPE_HOME=$STRIPE_PROJ/main/default
STRIPE_SCRIPTS=$STRIPE_PROJ/scripts/shell
