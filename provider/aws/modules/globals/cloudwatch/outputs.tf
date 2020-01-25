output cloudwatch_log_group_inbound_flow_logs_arn {
  value = aws_cloudwatch_log_group.inbound_flow_logs.arn
}

output cloudwatch_log_group_outbound_flow_logs_arn {
  value = aws_cloudwatch_log_group.outbound_flow_logs.arn
}
