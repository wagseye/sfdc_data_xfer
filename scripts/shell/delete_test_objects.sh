#!/bin/bash

CWD="$(dirname "$(which "$0")")"
source $CWD/init.sh

sf apex run --file=$PROJECT_HOME/scripts/apex/delete_test_objects.apex