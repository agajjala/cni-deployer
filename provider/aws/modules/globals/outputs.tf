output cloudwatch_log_group_inbound_flow_logs_arn {
  value = module.cloudwatch.cloudwatch_log_group_inbound_flow_logs_arn
}

output cloudwatch_log_group_outbound_flow_logs_arn {
  value = module.cloudwatch.cloudwatch_log_group_outbound_flow_logs_arn
}

output iam_role_flow_logs_arn {
  value = module.iam.iam_role_flow_logs_arn
}

output sns_topic_vpce_connections_arn {
  value = module.sns.sns_topic_vpce_connections_arn
}
