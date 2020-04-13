###############################
#  IAM Role
###############################

resource aws_iam_role monitoring_ec2 {
  name = local.monitoring_ec2_iam_role_name

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = var.tags
}

###############################
#  Instance Profile
###############################

resource aws_iam_instance_profile monitoring_ec2 {
  name_prefix  = local.monitoring_ec2_iam_role_name
  role         = aws_iam_role.monitoring_ec2.name
}

###############################
#  Role Policy Attachment
###############################

resource aws_iam_role_policy_attachment monitoring_ec2_ecr_access {
  policy_arn = aws_iam_policy.ecr_manage.arn
  role       = aws_iam_role.monitoring_ec2.name
}

resource aws_iam_role_policy_attachment monitoring_ec2_private_link_access {
  policy_arn = aws_iam_policy.private_link_admin.arn
  role       = aws_iam_role.monitoring_ec2.name
}