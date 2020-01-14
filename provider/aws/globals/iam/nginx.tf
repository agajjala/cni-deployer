###############################
#  Inbound (starts)
###############################

resource "aws_iam_role" "inbound_nginx" {
  name = "in-nginx-${var.deployment_id}"

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

resource "aws_iam_instance_profile" "inbound_nginx" {
  name  = "in-nginx-${var.deployment_id}"
  role  = aws_iam_role.inbound_nginx.name
}

resource "aws_iam_role_policy" "inbound_nginx" {
  name = "in-nginx-${var.deployment_id}"
  role = aws_iam_role.inbound_nginx.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Resource": "${var.inbound_nginx_s3_bucket_arn}"
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ]
    },
    {
      "Resource": "${var.inbound_nginx_ecr_repo_arn}",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "inbound_nginx_cloudwatch_write_access" {
  role       = aws_iam_role.inbound_nginx.name
  policy_arn = aws_iam_policy.cloudwatch_write_access.arn
}

###############################
#  Inbound (ends)
###############################

###############################
#  Outbound (starts)
###############################

resource "aws_iam_role" "outbound_nginx" {
  name = "out-nginx-${var.deployment_id}"

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

resource "aws_iam_instance_profile" "outbound_nginx" {
  name  = "out-nginx-${var.deployment_id}"
  role  = aws_iam_role.inbound_nginx.name
}

resource "aws_iam_role_policy" "outbound_nginx" {
  name = "out-nginx-${var.deployment_id}"
  role = aws_iam_role.inbound_nginx.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Resource": "${var.outbound_nginx_s3_bucket_arn}"
      "Effect": "Allow",
      "Action": [
        "s3:Get*",
        "s3:List*"
      ]
    },
    {
      "Resource": "${var.outbound_nginx_ecr_repo_arn}",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage",
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "outbound_nginx_cloudwatch_write_access" {
  role       = aws_iam_role.outbound_nginx.name
  policy_arn = aws_iam_policy.cloudwatch_write_access.arn
}

###############################
#  Outbound (ends)
###############################
