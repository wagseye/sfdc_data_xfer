#!/bin/bash

CWD="$(dirname "$(which "$0")")"

# This script is in a known location so we hardcode the path to the project's init script
source $CWD/../../../scripts/shell/init.sh

STRIPE_PROJ=$PROJECT_HOME/stripe-service
STRIPE_HOME=$STRIPE_PROJ/main/default