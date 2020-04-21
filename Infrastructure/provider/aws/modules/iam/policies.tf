resource aws_iam_policy cloudwatch_logs_write {
  name = "${var.resource_prefix}-cloudwatch-logs-w"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy private_link_event_handler {
  name = "${var.resource_prefix}-pl-event-handler"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:AcceptVpcEndpointConnections",
          "ec2:DescribeVpcEndpoints",
          "ec2:DescribeVpcEndpointConnections",
          "ec2:RejectVpcEndpointConnections"
        ],
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy cloudwatch_metrics_write {
  name = "${var.resource_prefix}-cloudwatch-metrics-w"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:PutMetricData"
        ],
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy private_link_admin {
  name = "${var.resource_prefix}-pl-admin"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
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
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy route53_read_write {
  name = "${var.resource_prefix}-r53-rw"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        Resource = "*"
      }
    ]
  })
}

# TODO: Revisit why lambdas require access across inbound and outbound tables
resource aws_iam_policy dynamodb_read_write {
  name = "${var.resource_prefix}-ddb-rw"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
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
        ]
        Effect = "Allow"
        Resource = flatten([
          formatlist("arn:aws:dynamodb:%s:${data.aws_caller_identity.current.account_id}:table/*", [var.region])
        ])
      }
    ]
  })
}

resource aws_iam_policy dynamodb_read {
  name = "${var.resource_prefix}-ddb-r"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Scan",
          "dynamodb:Query",
          "dynamodb:BatchGetItem",
          "dynamodb:DescribeTable",
          "dynamodb:ConditionCheckItem"
        ]
        Effect = "Allow"
        Resource = flatten([
          formatlist("arn:aws:dynamodb:%s:${data.aws_caller_identity.current.account_id}:table/*", [var.region])
        ])
      }
    ]
  })
}

resource aws_iam_policy sns_write {
  name = "${var.resource_prefix}-sns-w"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy attach_eip {
  name = "${var.resource_prefix}-attach-eip"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeNetworkInterfaces",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:AttachNetworkInterface"
        ],
        Resource = "*"
      }
    ]
  })
}

resource aws_iam_policy ecr_manage {
  name = "${var.resource_prefix}-ecr-manage"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage"
        ],
        Resource = "*"
      }
    ]
  })
}
