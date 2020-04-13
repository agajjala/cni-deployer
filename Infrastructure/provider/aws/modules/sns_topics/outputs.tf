output inbound_vpce_connections_topic {
  value = aws_sns_topic.inbound_vpce_connections
}

output inbound_vpce_connections_topic_kms_key {
  value = module.inbound_vpce_connections_kms_key
}

output outbound_vpce_connections_topic {
  value = aws_sns_topic.outbound_vpce_connections
}

output outbound_vpce_connections_topic_kms_key {
  value = module.outbound_vpce_connections_kms_key
}

output dynamodb_stream_fanout_topic {
  value = aws_sns_topic.dynamodb_stream_fanout
}

output dynamodb_stream_fanout_topic_kms_key {
  value = module.dynamodb_stream_fanout_kms_key
}
