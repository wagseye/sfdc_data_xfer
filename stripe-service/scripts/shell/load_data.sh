#!/bin/bash

set -e # exit on any errors

CWD="$(dirname "$(which "$0")")"

source $CWD/load_data_sources.sh
source $CWD/load_objects.sh
source $CWD/load_object_fields.sh
source $CWD/load_object_actions.sh

