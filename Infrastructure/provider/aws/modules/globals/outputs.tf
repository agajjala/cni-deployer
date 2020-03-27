output bastion_autoscaling_group_role_arn {
  value = module.iam.bastion_autoscaling_group_role_arn
}

output bastion_instance_profile_arn {
  value = module.iam.bastion_instance_profile_arn
}

output iam_role_flow_logs_arn {
  value = module.iam.flow_logs_role_arn
}

output data_plane_cluster_role_arn {
  value = module.iam.data_plane_cluster_role_arn
}

output data_plane_cluster_role_name {
  value = module.iam.data_plane_cluster_role_name
}

output data_plane_node_role_arn {
  value = module.iam.data_plane_node_role_arn
}

output data_plane_node_role_name {
  value = module.iam.data_plane_node_role_name
}

output private_link_access_role_arn {
  value = module.iam.ctrl_dynamodb_stream_fanout_role_name
}

output inbound_config_table_name {
  value = module.dynamodb.inbound_config_table_name
}

output inbound_config_hash_key {
  value = module.dynamodb.inbound_config_hash_key
}

output inbound_vpce_connections_topic_arn {
  value = module.sns.inbound_vpce_connections_topic_arn
}

output inbound_private_link_api_endpoint_role_arn {
  value = module.iam.ctrl_inbound_private_link_api_endpoint_role_arn
}

output outbound_config_table_name {
  value = module.dynamodb.outbound_config_table_name
}

output outbound_config_hash_key {
  value = module.dynamodb.outbound_config_hash_key
}

output outbound_vpce_connections_topic_arn {
  value = module.sns.outbound_vpce_connections_topic_arn
}

output outbound_private_link_api_endpoint_role_arn {
  value = module.iam.ctrl_outbound_private_link_api_endpoint_role_arn
}

output monitoring_ec2_instance_profile_name {
  value = module.iam.monitoring_ec2_instance_profile_name
}
