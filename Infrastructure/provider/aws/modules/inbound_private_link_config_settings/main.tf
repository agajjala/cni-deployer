resource aws_dynamodb_table_item auth {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "auth"},
    "Payload": {"S": "{\"cred_0\": \"${var.api_key}\"}"}
  })
}

resource aws_dynamodb_table_item info {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "info"},
    "Payload": {"S": "{\"service_name\": \"${var.vpc_endpoint_service_name}\"}"}
  })
}

resource aws_dynamodb_table_item route53 {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "route53"},
    "Payload": {"S": "{\"hosted_zoneid\": \"${var.hosted_zone_id}\", \"hosted_zone_domain\": \"${var.hosted_zone_name}.\"}"}
  })
}

resource aws_dynamodb_table_item endpoint {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "endpoint"},
    "Payload": {"S": "{\"service_id\": \"${var.vpc_endpoint_service_id}\"}"}
  })
}
