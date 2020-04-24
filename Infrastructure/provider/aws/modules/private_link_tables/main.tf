locals {
  hash_key = "id"
  private_links_table_global_secondary_indices = [
    {
      name : "EndpointId",
      type : "S"
    },
    {
      name : "OrgId",
      type : "S"
    },
    {
      name : "AwsAccountId",
      type : "S"
    },
    {
      name : "Domain",
      type : "S"
    },
    {
      name : "State",
      type : "S"
    }
  ]
}

###############################
#  Inbound
###############################

resource aws_dynamodb_table inbound {
  tags             = var.tags
  name             = "${var.resource_prefix}_InboundPrivateLinks"
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
}

###############################
#  Outbound
###############################

resource aws_dynamodb_table outbound {
  tags             = var.tags
  name             = "${var.resource_prefix}_OutboundPrivateLinks"
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
}

resource aws_dynamodb_table dynamodb_lock_table {
  name             = "${var.resource_prefix}_DynamoDBLockTable"
  billing_mode     = "PAY_PER_REQUEST"
  hash_key         = "lock_key"
  range_key        = "sort_key"
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES"

  server_side_encryption {
    enabled = true
  }

  point_in_time_recovery {
    enabled = var.enable_point_in_time_recovery
  }

  attribute {
    name = "lock_key"
    type = "S"
  }
  attribute {
    name = "sort_key"
    type = "S"
  }
  tags = var.tags
}
