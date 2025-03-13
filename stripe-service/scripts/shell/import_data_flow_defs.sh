#!/bin/bash

echo "Import data flow defs 1"
if [ -z "$PROJECT_HOME" ]; then
    CWD="$(dirname "$(which "$0")")"
    source $CWD/init.sh
fi

if [ -z "$PROJECT_HOME" ]; then
    echo "init.sh script has not been called" && exit 1;
fi

sf data import tree --files $STRIPE_PROJ/test_data/data_flow_definitions/Field_Mapping_Set__c-Field_Mapping__c-Data_Flow_Definition__c.json
