#!/bin/bash

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

TEMP_FILE=/tmp/dsi.csv

OUTPUT=`$PROJECT_HOME/scripts/shell/var_substitution.sh $STRIPE_PROJ/record_data/data_source_instances.csv`
if [ $? -ne 0 ];  then
    echo "$OUTPUT"
    exit 1;
else
    echo "$OUTPUT" > $TEMP_FILE
fi

sf data import bulk --file $TEMP_FILE \
                    --sobject Data_Source_Instance__c \
                    --wait 2
if [ $? -ne 0 ];  then
    echo "Import failed. Does the record already exist?"
fi

rm $TEMP_FILE
