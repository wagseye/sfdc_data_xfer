#!/bin/bash

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

sf data import tree --files $STRIPE_PROJ/test_data/data_flow_definitions/Field_Mapping_Set__c-Field_Mapping__c-Data_Flow_Definition__c.json