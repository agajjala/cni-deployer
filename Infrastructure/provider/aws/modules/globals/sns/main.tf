locals {
  vpce_connections_name = "${var.resource_prefix}-vpce-connections"
  stream_fanout_name    = "${var.resource_prefix}-dynamodb-stream-fanout"
}
