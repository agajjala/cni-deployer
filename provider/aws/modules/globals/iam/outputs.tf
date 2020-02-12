output bastion_autoscaling_group_role_arn {
  value = aws_iam_service_linked_role.bastion_autoscaling_group.arn
}

output bastion_instance_profile_arn {
  value = aws_iam_instance_profile.bastion.arn
}

output flow_logs_role_arn {
  value = aws_iam_role.flow_logs.arn
}

output ctrl_dynamodb_stream_fanout_role_arn {
  value = aws_iam_role.dynamodb_stream_fanout.arn
}

output ctrl_inbound_private_link_api_endpoint_role_arn {
  value = aws_iam_role.inbound_private_link_api_endpoint.arn
}

output ctrl_outbound_private_link_api_endpoint_role_arn {
  value = aws_iam_role.outbound_private_link_api_endpoint.arn
}

output ctrl_inbound_supervisor_role_arn {
  value = aws_iam_role.inbound_supervisor.arn
}

output ctrl_outbound_supervisor_role_arn {
  value = aws_iam_role.outbound_supervisor.arn
}

output ctrl_private_link_event_handler_role_arn {
  value = aws_iam_role.private_link_event_handler.arn
}

output ctrl_inbound_private_link_stream_role_arn {
  value = aws_iam_role.inbound_private_link_stream.arn
}

output ctrl_outbound_private_link_stream_role_arn {
  value = aws_iam_role.outbound_private_link_stream.arn
}

output data_plane_cluster_role_arn {
  value = aws_iam_role.data_plane_cluster.arn
}

output data_plane_cluster_role_name {
  value = aws_iam_role.data_plane_cluster.name
}

output data_plane_node_role_arn {
  value = aws_iam_role.data_plane_node.arn
}

output data_plane_node_role_name {
  value = aws_iam_role.data_plane_node.name
}
