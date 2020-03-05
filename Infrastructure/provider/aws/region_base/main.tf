provider aws {
  region = var.region
}

locals {
  admin_role_arn         = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
  artifact_bucket_name   = "sfdc-cni-artifacts-${var.env_name}-${var.region}"
  state_bucket_name      = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
  access_log_bucket_name = "sfdc-cni-access-logs-${var.env_name}-${var.region}"
  state_lock_table_name  = "tf-state-lock"
}

module artifact_bucket {
  source                 = "../modules/s3_bucket"
  tags                   = var.tags
  bucket_name            = local.artifact_bucket_name
  region                 = var.region
  admin_role_arn         = local.admin_role_arn
  enable_mfa_delete      = false
  access_log_bucket_name = module.access_log_bucket.bucket_name
}

module state_bucket {
  source                 = "../modules/s3_bucket"
  tags                   = var.tags
  bucket_name            = local.state_bucket_name
  region                 = var.region
  admin_role_arn         = local.admin_role_arn
  enable_mfa_delete      = false
  access_log_bucket_name = module.access_log_bucket.bucket_name
}

module access_log_bucket {
  source      = "../modules/access_log_bucket"
  tags        = var.tags
  region      = var.region
  bucket_name = local.access_log_bucket_name
}

module state_lock_table {
  source     = "../modules/state_lock_table"
  tags       = var.tags
  table_name = local.state_lock_table_name
}
