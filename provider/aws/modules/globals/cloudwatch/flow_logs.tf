module inbound_flow_logs_key {
  source         = "../../kms_key"
  tags           = var.tags
  key_name       = local.inbound_flow_logs_group_name
  admin_role_arn = var.admin_role_arn
  source_json    = data.aws_iam_policy_document.flow_logs_key_cloudwatch_access.json
}

resource aws_cloudwatch_log_group inbound_flow_logs {
  name              = local.inbound_flow_logs_group_name
  retention_in_days = var.flow_logs_retention_in_days
  kms_key_id        = module.inbound_flow_logs_key.key_arn

  tags              = var.tags
}

module outbound_flow_logs_key {
  source         = "../../kms_key"
  tags           = var.tags
  key_name       = local.outbound_flow_logs_group_name
  admin_role_arn = var.admin_role_arn
  source_json    = data.aws_iam_policy_document.flow_logs_key_cloudwatch_access.json
}

resource aws_cloudwatch_log_group outbound_flow_logs {
  name              = local.outbound_flow_logs_group_name
  retention_in_days = var.flow_logs_retention_in_days
  kms_key_id        = module.outbound_flow_logs_key.key_arn

  tags              = var.tags
}
