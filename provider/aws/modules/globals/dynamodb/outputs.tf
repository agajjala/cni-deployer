output inbound_private_links_stream_arn {
  value = aws_dynamodb_table.inbound_private_links.stream_arn
}

output outbound_private_links_stream_arn {
  value = aws_dynamodb_table.outbound_private_links.stream_arn
}
