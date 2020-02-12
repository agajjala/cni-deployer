module shared_policy_documents {
  source = "../shared_policy_documents"
}

module cluster_log {
  source              = "../log_group"
  tags                = var.tags
  log_group_name      = "/aws/eks/${var.resource_prefix}/cluster"
  retention_in_days   = var.retention_in_days
  admin_role_arn      = var.admin_role_arn
  kms_key_source_json = module.shared_policy_documents.kms_key_cloudwatch_access_json
}

resource aws_eks_cluster data_plane {
  name                      = var.resource_prefix
  role_arn                  = var.data_plane_cluster_role_arn
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
  role       = var.data_plane_cluster_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource aws_iam_role_policy_attachment service_policy {
  role       = var.data_plane_cluster_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
}
