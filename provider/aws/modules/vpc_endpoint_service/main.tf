resource aws_vpc_endpoint_service default {
  acceptance_required        = true
  network_load_balancer_arns = var.network_load_balancer_arns

  tags                       = var.tags
}

resource aws_vpc_endpoint_service_allowed_principal all_principals {
  vpc_endpoint_service_id = aws_vpc_endpoint_service.default.id
  principal_arn           = "*"
}

resource aws_vpc_endpoint_connection_notification vpce_connections {
  vpc_endpoint_service_id     = aws_vpc_endpoint_service.default.id
  connection_notification_arn = var.vpce_connections_topic_arn
  connection_events           = ["Accept", "Reject", "Connect", "Delete"]
}