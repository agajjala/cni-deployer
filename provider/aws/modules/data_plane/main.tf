###############################
#  Cluster
###############################

module shared_policy_documents {
  source = "../shared_policy_documents"
}

module cluster_log {
  source              = "../log_group"
  tags                = var.tags
  log_group_name      = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days   = var.retention_in_days
  admin_role_arn      = var.admin_role_arn
  kms_key_source_json = module.shared_policy_documents.kms_key_cloudwatch_access_json
}

resource aws_eks_cluster data_plane {
  name                      = var.cluster_name
  role_arn                  = var.cluster_role_arn
  enabled_cluster_log_types = var.enabled_cluster_log_types

  vpc_config {
    endpoint_private_access = true
    endpoint_public_access  = true
    subnet_ids              = var.subnet_ids
    security_group_ids      = var.cluster_security_group_ids
    public_access_cidrs     = var.public_access_cidrs
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_policy,
    aws_iam_role_policy_attachment.service_policy,
    module.cluster_log.log_group_arn
  ]
}

resource aws_iam_role_policy_attachment cluster_policy {
  role       = var.cluster_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource aws_iam_role_policy_attachment service_policy {
  role       = var.cluster_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}

###############################
#  Node Group
###############################

resource aws_eks_node_group data_plane {
  cluster_name    = aws_eks_cluster.data_plane.name
  node_group_name = var.cluster_name
  node_role_arn   = var.node_group_role_arn
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
  role       = var.node_group_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource aws_iam_role_policy_attachment data_plane_node_ecr_read_access {
  role       = var.node_group_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource aws_iam_role_policy_attachment data_plane_node_network_interface_access {
  role       = var.node_group_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
