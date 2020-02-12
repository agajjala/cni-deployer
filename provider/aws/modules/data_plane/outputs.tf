output remote_access_security_group_id {
  value = aws_eks_node_group.data_plane.resources[0].remote_access_security_group_id
}