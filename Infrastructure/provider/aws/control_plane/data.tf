data terraform_remote_state region_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "region_base"
    region = var.region
  }
}

data terraform_remote_state stack_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/stack_base"
    region = var.region
  }
}

###############################
#  API Key
###############################

data aws_secretsmanager_secret_version api_key {
  secret_id = "${local.resource_prefix}-api-key"
}
