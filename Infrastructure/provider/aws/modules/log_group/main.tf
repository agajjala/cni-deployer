module log_group_key {
  source             = "../kms_key"
  tags               = var.tags
  admin_role_arns     = var.admin_role_arns
  source_json_policy = var.kms_key_source_json
}

resource aws_cloudwatch_log_group log_group {
  name              = var.log_group_name
  retention_in_days = var.retention_in_days
  kms_key_id        = module.log_group_key.key_arn

  tags              = var.tags
}
