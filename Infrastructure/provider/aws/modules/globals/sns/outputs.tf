output inbound_vpce_connections_topic_arn {
  value = aws_sns_topic.inbound_vpce_connections.arn
}

output inbound_vpce_connections_kms_key_arn {
  value = module.inbound_vpce_connections_key.key_arn
}

output outbound_vpce_connections_topic_arn {
  value = aws_sns_topic.outbound_vpce_connections.arn
}

output outbound_vpce_connections_kms_key_arn {
  value = module.outbound_vpce_connections_key.key_arn
}

output dynamodb_stream_fanout_topic_arn {
  value = aws_sns_topic.dynamodb_stream_fanout.arn
}

output dynamodb_stream_fanout_kms_key_arn {
  value = module.dynamodb_stream_fanout_key.key_arn
}
