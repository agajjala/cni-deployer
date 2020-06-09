#!/bin/bash

set -eou pipefail

# Usage:
# ./teardown_aws.sh <PATH_TO_MANIFEST>
#
# Example:
# ./teardown_aws.sh Manifests/Dev/manifest.yaml

MANIFEST=${1}
DEPLOYER_PATH=Infrastructure/deployer
MODULE_PATH=Infrastructure/provider/aws
INBOUND_NAMESPACE=cni-inbound
OUTBOUND_NAMESPACE=cni-outbound

# source manifest variables
eval "$(python "$DEPLOYER_PATH/deployment_helper.py" -c "export_to_env" -manifest "${MANIFEST}")"
AWS_REGION="$TF_VAR_region"
export TF_IN_AUTOMATION=true

python "${DEPLOYER_PATH}/deploy.py" -c destroy -module $MODULE_PATH/monitoring -manifest "${MANIFEST}" -automation
python "${DEPLOYER_PATH}/deploy.py" -c destroy -module $MODULE_PATH/control_plane -manifest "${MANIFEST}" -automation

# generate k8s files using helm
make template

# delete k8s stuff for inbound
INBOUND_CLUSTER_NAME=$(aws ssm --region "$TF_VAR_region" get-parameter --with-decryption --name="/$TF_VAR_env_name-$TF_VAR_region/$TF_VAR_deployment_id/inbound-data-plane/cluster-name" | jq -r .Parameter.Value)
aws eks --region "$TF_VAR_region" update-kubeconfig --name "$INBOUND_CLUSTER_NAME"
kubectl delete -f "Manifests/Output/$INBOUND_CLUSTER_NAME/$INBOUND_NAMESPACE/templates/"

# delete k8s stuff for outbound
OUTBOUND_CLUSTER_NAME=$(aws ssm --region "$TF_VAR_region" get-parameter --with-decryption --name="/$TF_VAR_env_name-$TF_VAR_region/$TF_VAR_deployment_id/outbound-data-plane/$TF_VAR_vpc_suffix/cluster-name" | jq -r .Parameter.Value)
aws eks --region "$TF_VAR_region" update-kubeconfig --name "$OUTBOUND_CLUSTER_NAME"
kubectl delete -f "Manifests/Output/$TF_VAR_env_name-$TF_VAR_region-$TF_VAR_deployment_id-outbound-data-plane/$OUTBOUND_NAMESPACE/templates/"

python "$DEPLOYER_PATH/deploy.py" -c destroy -module $MODULE_PATH/outbound_data_plane -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c destroy -module $MODULE_PATH/inbound_data_plane -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c destroy -module $MODULE_PATH/stack_base -manifest "${MANIFEST}" -automation
