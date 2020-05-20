locals {
  resource_prefix          = "${var.env_name}-${var.region}"
  pipeline_role_expression = "${local.resource_prefix}-*-pipeline"
  admin_principals         = formatlist("arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/%s", concat(var.admin_role_names, [local.pipeline_role_expression]))
  state_bucket_name        = "sfdc-cni-tf-state-${local.resource_prefix}"
}

terraform {}

provider aws {
  region = var.region
}

module state_bucket {
  source            = "../modules/s3_bucket"
  tags              = var.tags
  bucket_name       = local.state_bucket_name
  region            = var.region
  admin_principals  = local.admin_principals
  enable_mfa_delete = false
  force_destroy     = var.force_destroy_state_bucket
}

resource aws_dynamodb_table lock_table {
  name           = "tf-state-lock"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"
  tags           = var.tags

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }
}
