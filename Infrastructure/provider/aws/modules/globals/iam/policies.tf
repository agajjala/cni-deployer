resource "aws_iam_policy" "cloudwatch_write_access" {
  name = "${var.resource_prefix}-cloudwatch-w"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_policy private_link_limited_access {
  name = "${var.resource_prefix}-pl-limited-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AcceptVpcEndpointConnections",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeVpcEndpointConnections",
        "ec2:RejectVpcEndpointConnections"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_policy cloudwatch_metric_write_access {
  name = "${var.resource_prefix}-cloudwatch-metrics-w"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
          "cloudwatch:PutMetricData"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_policy private_link_access {
  name = "${var.resource_prefix}-pl-access"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:AcceptVpcEndpointConnections",
        "ec2:CreateVpcEndpoint",
        "ec2:CreateVpcEndpointConnectionNotification",
        "ec2:DeleteVpcEndpoints",
        "ec2:DescribeVpcEndpointConnections",
        "ec2:DescribeVpcEndpointServices",
        "ec2:DescribeVpcEndpoints",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups",
        "ec2:DescribeNetworkInterfaces",
        "ec2:RejectVpcEndpointConnections"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_policy route53_read_write_access {
  name = "${var.resource_prefix}-r53-rw"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "route53:ChangeResourceRecordSets",
        "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# TODO: Revisit why lambdas require access across inbound and outbound tables
resource aws_iam_policy dynamodb_read_write_access {
  name = "${var.resource_prefix}-ddb-rw"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:DeleteItem",
        "dynamodb:PutItem",
        "dynamodb:Scan",
        "dynamodb:Query",
        "dynamodb:UpdateItem",
        "dynamodb:BatchWriteItem",
        "dynamodb:BatchGetItem",
        "dynamodb:DescribeTable",
        "dynamodb:ConditionCheckItem"
      ],
      "Effect": "Allow",
      "Resource": [
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_InboundConfigSettings",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_InboundConfigSettings/index/*",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_InboundPrivateLinks",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_InboundPrivateLinks/index/*",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_OutboundConfigSettings",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_OutboundConfigSettings/index/*",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_OutboundPrivateLinks",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.resource_prefix}_OutboundPrivateLinks/index/*",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/DynamoDBLockTable",
        "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/DynamoDBLockTable/index/*"
      ]
    }
  ]
}
EOF
}

# TODO: obtain the exact topic(s) to publish to
resource aws_iam_policy sns_publish {
  name = "${var.resource_prefix}-sns-publish"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource aws_iam_policy ecr_manage {
  name = "${var.resource_prefix}-ecr-manage"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Resource": "*",
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetRepositoryPolicy",
        "ecr:DescribeRepositories",
        "ecr:ListImages",
        "ecr:DescribeImages",
        "ecr:BatchGetImage"
      ]
    }
  ]
}
EOF
}
