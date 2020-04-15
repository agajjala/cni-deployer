#!/bin/bash

set -eou pipefail

MANIFEST=${1}
DEPLOYER_PATH=Infrastructure/deployer
MODULE_PATH=Infrastructure/provider/aws

export TF_IN_AUTOMATION=true

python "$DEPLOYER_PATH/deploy.py" -c plan -module $MODULE_PATH/state_bucket -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c apply -module $MODULE_PATH/state_bucket -manifest "${MANIFEST}" -automation

python "$DEPLOYER_PATH/deploy.py" -c plan -module $MODULE_PATH/region_base -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c apply -module $MODULE_PATH/region_base -manifest "${MANIFEST}" -automation
