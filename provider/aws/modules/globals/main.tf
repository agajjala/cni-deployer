locals {
  admin_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
}

module iam {
  source                       = "./iam"
  region                       = var.region
  resource_prefix              = var.resource_prefix
  tags                         = var.tags
  inbound_nginx_ecr_repo_arn   = var.inbound_nginx_ecr_repo_arn
  inbound_nginx_s3_bucket_arn  = var.inbound_nginx_s3_bucket_arn
  outbound_nginx_ecr_repo_arn  = var.outbound_nginx_ecr_repo_arn
  outbound_nginx_s3_bucket_arn = var.outbound_nginx_s3_bucket_arn
}

module cloudwatch {
  source                      = "./cloudwatch"
  resource_prefix             = var.resource_prefix
  tags                        = var.tags
  flow_logs_retention_in_days = var.flow_logs_retention_in_days
  admin_role_arn              = local.admin_role_arn
}

module sns {
  source          = "./sns"
  resource_prefix = var.resource_prefix
  tags            = var.tags
  admin_role_arn  = local.admin_role_arn
}
