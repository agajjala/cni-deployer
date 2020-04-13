module shared_policy_documents {
  source = "../shared_policy_documents"
}

module flow_log {
  source              = "../log_group"
  tags                = var.tags
  admin_role_arns      = var.admin_role_arns
  kms_key_source_json = module.shared_policy_documents.kms_key_cloudwatch_access_json
  log_group_name      = "${var.resource_prefix}-flow-logs"
  retention_in_days   = var.retention_in_days
}

resource aws_flow_log all_traffic {
  iam_role_arn    = var.flow_logs_iam_role_arn
  log_destination = module.flow_log.log_group_arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}
