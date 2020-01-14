###############################
#  Inbound (starts)
###############################

resource "aws_iam_role" "inbound_bastion" {
  name = "in-bastion-${var.deployment_id}"

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
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "inbound_bastion" {
  name_prefix  = "in-bastion-${var.deployment_id}"
  role         = aws_iam_role.inbound_bastion.name
}

###############################
#  Inbound (ends)
###############################

###############################
#  Outbound (starts)
###############################

resource "aws_iam_role" "outbound_bastion" {
  name = "out-bastion-${var.deployment_id}"

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
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = var.tags
}

resource "aws_iam_instance_profile" "outbound_bastion" {
  name_prefix  = "outbound-bastion-${var.deployment_id}"
  role         = aws_iam_role.outbound_bastion.name
}

###############################
#  Outbound (ends)
###############################
