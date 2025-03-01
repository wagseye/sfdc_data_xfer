#!/bin/bash

set -e # exit on any errors

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

sf org create scratch --set-default --definition-file config/project-scratch-def.json --alias data-xfer-dev --duration-days 14
STRIPE_SCRIPTS=$PROJECT_HOME/stripe-service/scripts/shell/.

source $STRIPE_SCRIPTS/load_data.sh
source $STRIPE_SCRIPTS/import_data_flow_defs.sh
