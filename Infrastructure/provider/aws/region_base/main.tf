terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix          = "${var.env_name}-${var.region}"
  pipeline_role_expression = "${local.resource_prefix}-*-pipeline"
  admin_principals         = formatlist("arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/%s", concat(var.admin_role_names, [local.pipeline_role_expression]))
  artifact_bucket_name     = "sfdc-cni-artifacts-${local.resource_prefix}"
  access_log_bucket_name   = "sfdc-cni-access-logs-${local.resource_prefix}"
}

module artifact_bucket {
  source                 = "../modules/s3_bucket"
  tags                   = var.tags
  bucket_name            = local.artifact_bucket_name
  region                 = var.region
  admin_principals       = local.admin_principals
  enable_mfa_delete      = false
  access_log_bucket_name = module.access_log_bucket.bucket_name
  force_destroy          = var.force_destroy_artifact_bucket
}

module access_log_bucket {
  source        = "../modules/access_log_bucket"
  tags          = var.tags
  region        = var.region
  bucket_name   = local.access_log_bucket_name
  force_destroy = var.force_destroy_access_log_bucket
}
