###############################
#  IAM Role
###############################

resource aws_iam_role api_gateway_logs {
  tags = var.tags
  name = "${var.resource_prefix}-api-gateway-logs"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })
}

###############################
#  Policy
###############################

resource aws_iam_role_policy api_gateway_logs {
  name = "${var.resource_prefix}-api-gateway-logs"
  role = aws_iam_role.api_gateway_logs.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}
