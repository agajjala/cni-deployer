output inbound_config_table_name {
  value = aws_dynamodb_table.inbound_config_settings.id
}

output inbound_config_hash_key {
  value = local.inbound_config_hash_key
}

output inbound_private_links_stream_arn {
  value = aws_dynamodb_table.inbound_private_links.stream_arn
}

output outbound_config_table_name {
  value = aws_dynamodb_table.outbound_config_settings.id
}

output outbound_config_hash_key {
  value = local.outbound_config_hash_key
}

output outbound_private_links_stream_arn {
  value = aws_dynamodb_table.outbound_private_links.stream_arn
}
