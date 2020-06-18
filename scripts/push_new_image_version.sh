#!/bin/bash

set -eou pipefail

# Usage:
# ./push_new_image_version.sh <STRATA_IMAGE_VERSION> <REGION_1> <REGION_2> ..
#
# Example:
# ./push_new_image_version.sh 280 us-west-2 us-east-1

STRATA_IMAGE_VERSION=$1
REGIONS=("${@:2}")
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

CNI_IMAGES=( "cni-metrics-exporter" "cni-monitoring" "cni-nginx-proxy-inbound" "cni-nginx-proxy-outbound" )
docker login dva-registry.internal.salesforce.com
for imageName in "${CNI_IMAGES[@]}"
do
  docker pull dva-registry.internal.salesforce.com/dva/sdn/"$imageName":"$STRATA_IMAGE_VERSION"
  printf "Pushing %s to ECR...\n" "${imageName}"
  for region in "${REGIONS[@]}"
  do
    ECR_REGISTRY_URL="$ACCOUNT_ID.dkr.ecr.$region.amazonaws.com"
    ECR_IMAGE_NAME="$ECR_REGISTRY_URL/$imageName"
    ECR_IMAGE_NAME_TAG="$ECR_IMAGE_NAME:$STRATA_IMAGE_VERSION"

    aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$ECR_REGISTRY_URL"
    docker tag dva-registry.internal.salesforce.com/dva/sdn/"$imageName":"$STRATA_IMAGE_VERSION" "$ECR_IMAGE_NAME_TAG"
    docker push "$ECR_IMAGE_NAME_TAG"
  done
done
