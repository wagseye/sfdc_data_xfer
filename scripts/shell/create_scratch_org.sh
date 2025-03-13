#!/bin/bash

set -e # exit on any errors

if [ -z "$PROJECT_HOME" ]; then
    CWD="$(dirname "$(which "$0")")"
    source $CWD/init.sh
fi
if [ -z "$PROJECT_HOME" ]; then
    echo "init.sh script has not been called" && exit 1;
fi


if [ -z "$ORG_ALIAS" ]; then
  ORG_ALIAS="data-xfer-dev"
fi

sf org create scratch --set-default --definition-file config/project-scratch-def.json --alias $ORG_ALIAS --duration-days 14
STRIPE_SCRIPTS=$PROJECT_HOME/stripe-service/scripts/shell

# The load_data script is for custom metadata types, and the load creates files to be synced via project deploy.
# The import_data_flow script directly imports sObject records, so we need to do the deploy first so the types are available for the import
source $STRIPE_SCRIPTS/load_data.sh

sf project deploy start

source $STRIPE_SCRIPTS/import_data_flow_defs.sh
