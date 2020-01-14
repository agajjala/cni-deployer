data "aws_iam_role" "flow_logs" {
  name = "flow-logs-${var.deployment_id}"
}

data "aws_cloudwatch_log_group" "log_group" {
  name = "${local.vpc_type}-flow-logs-${var.deployment_id}"
}
