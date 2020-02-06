output iam_role_flow_logs_arn {
  value = module.iam.flow_logs_role_arn
}

output vpce_connections_topic_arn {
  value = module.sns.vpce_connections_topic_arn
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
