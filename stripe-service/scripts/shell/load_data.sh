#!/bin/bash

set -e # exit on any errors

if [ -z "$PROJECT_HOME" ]; then
    CWD="$(dirname "$(which "$0")")"
    source $CWD/init.sh
fi

if [ -z "$PROJECT_HOME" ]; then
    echo "init.sh script has not been called" && exit 1;
fi

source $STRIPE_SCRIPTS/load_data_sources.sh
source $STRIPE_SCRIPTS/load_objects.sh
source $STRIPE_SCRIPTS/load_object_fields.sh
source $STRIPE_SCRIPTS/load_object_actions.sh

