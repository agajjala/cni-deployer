###############################
#  Control Plane
###############################

output authorizer_invocation_role {
  value = aws_iam_role.authorizer_invocation
}

output authorizer_role {
  value = aws_iam_role.authorizer
}

output private_connect_role {
  value = aws_iam_role.private_connect
}

output rest_api_endpoint_role {
  value = aws_iam_role.rest_api_endpoint
}

output supervisor_role {
  value = aws_iam_role.supervisor
}

output private_link_event_handler_role {
  value = aws_iam_role.private_link_event_handler
}

output private_link_stream_role {
  value = aws_iam_role.private_link_stream
}

###############################
#  Data Plane
###############################

output flow_logs_role {
  value = aws_iam_role.flow_logs
}

output bastion_autoscaling_group_role {
  value = aws_iam_service_linked_role.bastion_autoscaling_group
}

output bastion_instance_profile {
  value = aws_iam_instance_profile.bastion
}

output data_plane_cluster_role {
  value = aws_iam_role.data_plane_cluster
}

output data_plane_node_group_role {
  value = aws_iam_role.data_plane_node_group
}

###############################
#  Monitoring
###############################

output monitoring_ec2_role {
  value = aws_iam_role.monitoring_ec2
}

output monitoring_ec2_instance_profile {
  value = aws_iam_instance_profile.monitoring_ec2
}
