#!/bin/bash

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

sf data export tree --query $STRIPE_PROJ/scripts/soql/query_data_flow_defs_and_mappings.soql --output-dir $STRIPE_PROJ/test_data/data_flow_definitions
