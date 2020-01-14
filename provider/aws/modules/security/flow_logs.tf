resource "aws_flow_log" "all_traffic" {
  iam_role_arn    = var.flow_logs_iam_role_arn
  log_destination = var.flow_logs_cloudwatch_group_arn
  traffic_type    = "ALL"
  vpc_id          = var.vpc_id
}
