resource aws_dynamodb_table outbound_private_links {
  name             = "${var.resource_prefix}_OutboundPrivateLinks"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "id"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = "id"
    type = "S"
  }

  dynamic "attribute" {
    for_each = local.private_links_table_global_secondary_indices
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    iterator = attribute
    for_each = local.private_links_table_global_secondary_indices
    content {
      name            = "${attribute.value.name}-index"
      hash_key        = attribute.value.name
      projection_type = "ALL"
    }
  }

  tags = var.tags
}
