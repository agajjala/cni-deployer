locals {
  inbound_vpce_connections_name  = "${var.resource_prefix}-inbound-vpce-connections"
  outbound_vpce_connections_name = "${var.resource_prefix}-outbound-vpce-connections"
  stream_fanout_name             = "${var.resource_prefix}-dynamodb-stream-fanout"
}
