resource aws_eks_node_group data_plane {
  cluster_name    = aws_eks_cluster.data_plane.name
  node_group_name = var.resource_prefix
  node_role_arn   = var.data_plane_node_role_arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key               = var.node_group_key_name
    source_security_group_ids = [
      var.bastion_security_group_id
    ]
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.data_plane_node_worker_policy,
    aws_iam_role_policy_attachment.data_plane_node_ecr_read_access,
    aws_iam_role_policy_attachment.data_plane_node_network_interface_access
  ]

  tags = var.tags
}

resource aws_iam_role_policy_attachment data_plane_node_worker_policy {
  role       = var.data_plane_node_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource aws_iam_role_policy_attachment data_plane_node_ecr_read_access {
  role       = var.data_plane_node_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource aws_iam_role_policy_attachment data_plane_node_network_interface_access {
  role       = var.data_plane_node_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
