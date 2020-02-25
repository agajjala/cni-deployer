output vpce_connections_topic_arn {
  value = aws_sns_topic.vpce_connections.arn
}

output dynamodb_stream_fanout_topic_arn {
  value = aws_sns_topic.dynamodb_stream_fanout.arn
}
