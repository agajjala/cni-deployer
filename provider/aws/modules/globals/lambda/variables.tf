variable resource_prefix {}
variable tags {
  type = map(string)
}
variable memory_size {}
variable artifact_bucket {}
variable layer_s3_key {}
variable layer_s3_object_version {
  default = ""
}
variable function_s3_key {}
variable function_s3_object_version {
  default = ""
}
variable inbound_supervisor_role_arn {}
variable outbound_supervisor_role_arn {}
variable dynamodb_stream_fanout_role_arn {}
variable inbound_private_link_stream_arn {}
variable outbound_private_link_stream_arn {}
variable private_link_event_handler_role_arn {}
variable inbound_private_link_api_endpoint_role_arn {}
variable outbound_private_link_api_endpoint_role_arn {}
variable inbound_private_link_stream_role_arn {}
variable outbound_private_link_stream_role_arn {}
variable dynamodb_stream_fanout_topic_arn {}
variable vpce_connections_topic_arn {}
