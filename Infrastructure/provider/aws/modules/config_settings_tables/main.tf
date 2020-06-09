locals {
  hash_key = "id"
}

###############################
#  Inbound
###############################

resource aws_dynamodb_table inbound {
  name             = "${var.resource_prefix}_InboundConfigSettings"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = local.hash_key
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = local.hash_key
    type = "S"
  }

  tags = var.tags
}

resource aws_dynamodb_table_item inbound_auth {
  table_name = aws_dynamodb_table.inbound.name
  hash_key   = local.hash_key

  item = jsonencode({
    "${local.hash_key}" = {
      "S" = "auth"
    }
    "Payload" = {
      "S" = "{\"cred_0\": \"${var.api_key}\"}"
    }
  })
}

###############################
#  Outbound
###############################

resource aws_dynamodb_table outbound {
  name             = "${var.resource_prefix}_OutboundConfigSettings"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = local.hash_key
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = local.hash_key
    type = "S"
  }

  tags = var.tags
}

resource aws_dynamodb_table_item outbound_auth {
  table_name = aws_dynamodb_table.outbound.name
  hash_key   = local.hash_key

  item = jsonencode({
    "${local.hash_key}" = {
      "S" = "auth"
    }
    "Payload" = {
      "S" = "{\"cred_0\": \"${var.api_key}\"}"
    }
  })
}

resource aws_dynamodb_table_item outbound_info {
  table_name = aws_dynamodb_table.outbound.name
  hash_key   = local.hash_key

  item = jsonencode({
    "${local.hash_key}" = {
      "S" = "info"
    }
    "Payload" = {
      "S" = "{\"iam_role\": \"${var.private_link_access_role.arn}\"}"
    }
  })
}

resource aws_dynamodb_table_item outbound_route53 {
  table_name = aws_dynamodb_table.outbound.name
  hash_key   = local.hash_key

  item = jsonencode({
    "${local.hash_key}" = {
      "S" = "route53"
    }
    "Payload" = {
      "S" = "{\"hosted_zoneid\": \"${var.outbound_zone.id}\", \"hosted_zone_domain\": \"${var.outbound_zone.name}\"}"
    }
  })
}

resource aws_dynamodb_table_item outbound_connection_notification_topic {
  table_name = aws_dynamodb_table.outbound.name
  hash_key   = local.hash_key

  item = jsonencode({
    "${local.hash_key}" = {
      "S" : "connection_notification_topic"
    }
    "Payload" = {
      "S" : "\"${var.outbound_vpce_connections_topic.arn}\""
    }
  })
}

