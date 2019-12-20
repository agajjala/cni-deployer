resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = "${var.vpc_type}-flow-logs-${var.deployment_id}"
  retention_in_days = "${var.flow_logs_retention_in_days}"

  tags              = "${var.tags}"
}

resource "aws_flow_log" "all_traffic" {
  iam_role_arn    = "${var.flow_logs_iam_role_arn}"
  log_destination = "${aws_cloudwatch_log_group.flow_logs.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${var.vpc_id}"
}
