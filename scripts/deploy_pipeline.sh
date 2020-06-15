#!/bin/bash

set -eou pipefail

# Usage:
# ./deploy_pipeline.sh <PATH TO MANIFEST FILE>
#
# Example:
# ./deploy_pipeline.sh ../../cni-manifests/aws/dev/dev-us-east-2-kev-test.yaml

SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
INFRA_CODE_PATH="$SCRIPTS_DIR/../Infrastructure"

MANIFEST_PATH=$1

python "$INFRA_CODE_PATH/deployer/deploy.py" -c plan -module "$INFRA_CODE_PATH/provider/aws/pipeline/" -manifest "$MANIFEST_PATH"
python "$INFRA_CODE_PATH/deployer/deploy.py" -c apply -module "$INFRA_CODE_PATH/provider/aws/pipeline/" -manifest "$MANIFEST_PATH"
