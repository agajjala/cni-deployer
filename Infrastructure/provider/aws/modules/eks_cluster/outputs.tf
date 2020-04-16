output remote_access_security_group_id {
  value = aws_eks_node_group.data_plane.resources[0].remote_access_security_group_id
}

output cluster {
  value = aws_eks_cluster.data_plane
}

output node_group {
  value = aws_eks_node_group.data_plane
}

output cluster_security_group_id {
  value = aws_eks_cluster.data_plane.vpc_config[0].cluster_security_group_id
}
