#!/bin/bash

set -eou pipefail

# Usage:
# ./push_new_image_version.sh <IMAGE_NAME> <NEW_IMAGE_VERSION> <REGION_1> <REGION_2> ..
#
# Example:
# ./push_new_image_version.sh cni-metrics-exporter 1 us-west-2 us-east-1

IMAGE_NAME=$1
NEW_IMAGE_VERSION=$2
REGIONS=("${@:3}")
ACCOUNT_ID=$(aws sts get-caller-identity | jq -r '.Account')

docker pull dva-registry.internal.salesforce.com/dva/sdn/"$IMAGE_NAME":latest

IMAGE_ID=$(docker images --format='{{json .}}' | grep "$IMAGE_NAME" | grep latest | jq -r '.ID')

for region in "${REGIONS[@]}"
do
  ECR_IMAGE_NAME="$ACCOUNT_ID.dkr.ecr.$region.amazonaws.com/$IMAGE_NAME"
  ECR_IMAGE_NAME_TAG="$ECR_IMAGE_NAME:$NEW_IMAGE_VERSION"

  aws ecr get-login-password --region "$region" | docker login --username AWS --password-stdin "$ECR_IMAGE_NAME"
  docker tag "$IMAGE_ID" "$ECR_IMAGE_NAME_TAG"
  docker push "$ECR_IMAGE_NAME_TAG"
done
