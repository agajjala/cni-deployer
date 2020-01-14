resource "aws_cloudwatch_log_group" "inbound_flow_logs" {
  name              = "inbound-flow-logs-${var.deployment_id}"
  retention_in_days = var.flow_logs_retention_in_days

  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "outbound_flow_logs" {
  name              = "outbound-flow-logs-${var.deployment_id}"
  retention_in_days = var.flow_logs_retention_in_days

  tags              = var.tags
}
