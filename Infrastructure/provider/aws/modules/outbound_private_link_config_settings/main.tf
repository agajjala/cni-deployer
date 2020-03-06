locals {
  formatted_proxy_url = format("%s://%s:%d", var.nlb_protocol, var.nlb_dns_name, var.nlb_port)
}

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
    "Payload": {"S": "{\"iam_role\": \"${var.private_link_access_role_arn}\"}"}
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

resource aws_dynamodb_table_item connection_notification_topic {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "connectionNotificationTopic"},
    "Payload": {"S": "\"${var.vpce_connections_topic_arn}\""}
  })
}

resource aws_dynamodb_table_item infra_vpcs {
  table_name = var.table_name
  hash_key   = var.table_hash_key

  item = jsonencode({
    "${var.table_hash_key}": {"S": "infra_vpcs"},
    "Payload": {"S": "[{\"vpc_id\": \"${var.vpc_id}\", \"subnet_ids\": ${jsonencode(var.private_subnet_ids)}, \"proxy_url\": \"${local.formatted_proxy_url}\", \"status\": \"inService\", \"total_capacity\": 100, \"security_group_ids\": [\"${var.nginx_sg_id}\"]}]"}
  })
}