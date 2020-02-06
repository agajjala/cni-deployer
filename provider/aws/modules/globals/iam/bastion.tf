###############################
#  Inbound
###############################

resource "aws_iam_role" "inbound_bastion" {
  name = local.inbound_bastion_iam_role_name

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

resource "aws_iam_instance_profile" "inbound_bastion" {
  name_prefix  = local.inbound_bastion_iam_role_name
  role         = aws_iam_role.inbound_bastion.name
}

###############################
#  Outbound
###############################

resource "aws_iam_role" "outbound_bastion" {
  name = local.outbound_bastion_iam_role_name

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

resource "aws_iam_instance_profile" "outbound_bastion" {
  name_prefix  = local.outbound_bastion_iam_role_name
  role         = aws_iam_role.outbound_bastion.name
}
