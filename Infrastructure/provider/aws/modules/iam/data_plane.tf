###############################
#  Cluster
###############################

resource aws_iam_role data_plane_cluster {
  tags = var.tags
  name = "${var.resource_prefix}-dp-cluster"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

###############################
#  Node Group
###############################

resource aws_iam_role data_plane_node_group {
  tags = var.tags
  name = "${var.resource_prefix}-dp-node-group"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource aws_iam_role_policy_attachment data_plane_node_group_cloudwatch_agent_access {
  role       = aws_iam_role.data_plane_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource aws_iam_role_policy_attachment data_plane_node_group_cloudwatch_read_access {
  role       = aws_iam_role.data_plane_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

resource aws_iam_role_policy_attachment data_plane_node_group_secrets_manager_access {
  role       = aws_iam_role.data_plane_node_group.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}


resource aws_iam_role_policy_attachment data_plane_node_group_autoscaling {
  role       = aws_iam_role.data_plane_node_group.name
  policy_arn = aws_iam_policy.data_plane_node_group_autoscaling.arn
}

resource aws_iam_policy data_plane_node_group_autoscaling {
  name = "${var.resource_prefix}-dp-node-autoscaling"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ]
        Resource = formatlist("arn:aws:autoscaling:%s:${data.aws_caller_identity.current.account_id}:autoScalingGroup:*:autoScalingGroupName/*", [var.region])
      },
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeTags"
        ]
        Resource = "*"
      }
    ]
  })
}
