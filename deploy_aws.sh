#!/bin/bash

set -eou pipefail

# Usage:
# ./deploy_aws.sh <PATH_TO_MANIFEST>
#
# Example:
# ./deploy_aws.sh Manifests/Dev/manifest.yaml

wait_for_lb_dns_name () {
  LB_DNS_NAME=""
  local namespace="$1"
  local current_seconds="$SECONDS"
  local wait_duration=300
  local stop_seconds=$(( current_seconds + wait_duration ))

  while [ -z "$LB_DNS_NAME" ] | [ "$stop_seconds" -gt "$SECONDS" ]; do
    echo "Waiting for load balancer DNS name.."
    LB_DNS_NAME=$(kubectl get svc -n "$namespace" -o=jsonpath='{.items[0].status.loadBalancer.ingress[0].hostname}')
    [ -z "$LB_DNS_NAME" ] && sleep 5
  done

  if [ "$SECONDS" -ge "$stop_seconds" ]; then
    echo "Timed out while provisioning load balancer DNS name"
    exit 1
  fi
  return 0
}

get_lb_arn () {
  LB_ARN=""
  local lb_name
  lb_name=$(echo "$LB_DNS_NAME" | awk -F'.' '{print $1}' | awk -F'-' '{print $1}')
  LB_ARN=$(aws --region "$AWS_REGION" elbv2 describe-load-balancers --names "$lb_name" | jq -r '.LoadBalancers[0].LoadBalancerArn')
}

enable_ppv2_header () {
  local target_group_arn
  target_group_arn=$(aws --region "$AWS_REGION" elbv2 describe-target-groups --load-balancer-arn "$LB_ARN" --max-items 1 | jq -r '.TargetGroups[0].TargetGroupArn')
  aws --region "$AWS_REGION" elbv2 modify-target-group-attributes --target-group-arn "$target_group_arn" --attributes Key=proxy_protocol_v2.enabled,Value=true
}

enable_cross_zone_lb () {
  aws --region "$AWS_REGION" elbv2 modify-load-balancer-attributes --load-balancer-arn "$LB_ARN" --attributes Key=load_balancing.cross_zone.enabled,Value=true
}

MANIFEST=${1}
DEPLOYER_PATH=Infrastructure/deployer
MODULE_PATH=Infrastructure/provider/aws
INBOUND_NAMESPACE=cni-inbound
OUTBOUND_NAMESPACE=cni-outbound

# source manifest variables
eval "$(python "$DEPLOYER_PATH/export_to_env.py" -manifest "${MANIFEST}")"
AWS_REGION="$TF_VAR_region"
export TF_IN_AUTOMATION=true

python "$DEPLOYER_PATH/deploy.py" -c plan -module $MODULE_PATH/stack_base -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c apply -module $MODULE_PATH/stack_base -manifest "${MANIFEST}" -automation

python "$DEPLOYER_PATH/deploy.py" -c plan -module $MODULE_PATH/inbound_data_plane -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c apply -module $MODULE_PATH/inbound_data_plane -manifest "${MANIFEST}" -automation

python "$DEPLOYER_PATH/deploy.py" -c plan -module $MODULE_PATH/outbound_data_plane -manifest "${MANIFEST}" -automation
python "$DEPLOYER_PATH/deploy.py" -c apply -module $MODULE_PATH/outbound_data_plane -manifest "${MANIFEST}" -automation

# generate k8s files using helm
make template

# deploy k8s services for inbound
INBOUND_CLUSTER_NAME=$(aws ssm --region "$TF_VAR_region" get-parameter --with-decryption --name="/$TF_VAR_env_name-$TF_VAR_region/$TF_VAR_deployment_id/inbound-data-plane/cluster-name" | jq -r .Parameter.Value)
aws eks --region "$TF_VAR_region" update-kubeconfig --name "$INBOUND_CLUSTER_NAME"
kubectl apply -f "Manifests/Output/$INBOUND_CLUSTER_NAME/$INBOUND_NAMESPACE/templates/"
wait_for_lb_dns_name "$INBOUND_NAMESPACE"
get_lb_arn "$LB_DNS_NAME"
enable_cross_zone_lb
enable_ppv2_header

# deploy k8s services for outbound
OUTBOUND_CLUSTER_NAME=$(aws ssm --region "$TF_VAR_region" get-parameter --with-decryption --name="/$TF_VAR_env_name-$TF_VAR_region/$TF_VAR_deployment_id/outbound-data-plane/$TF_VAR_vpc_suffix/cluster-name" | jq -r .Parameter.Value)
aws eks --region "$TF_VAR_region" update-kubeconfig --name "$OUTBOUND_CLUSTER_NAME"
# TODO: Need to Loop for multiple Outbound VPCs
kubectl apply -f "Manifests/Output/$TF_VAR_env_name-$TF_VAR_region-$TF_VAR_deployment_id-outbound-1-data-plane/$OUTBOUND_NAMESPACE/templates/"
wait_for_lb_dns_name "$OUTBOUND_NAMESPACE"
get_lb_arn "$LB_DNS_NAME"
enable_cross_zone_lb

python "${DEPLOYER_PATH}/deploy.py" -c plan -module $MODULE_PATH/control_plane -manifest "${MANIFEST}" -automation
python "${DEPLOYER_PATH}/deploy.py" -c apply -module $MODULE_PATH/control_plane -manifest "${MANIFEST}" -automation

python "${DEPLOYER_PATH}/deploy.py" -c plan -module $MODULE_PATH/monitoring -manifest "${MANIFEST}" -automation
python "${DEPLOYER_PATH}/deploy.py" -c apply -module $MODULE_PATH/monitoring -manifest "${MANIFEST}" -automation
