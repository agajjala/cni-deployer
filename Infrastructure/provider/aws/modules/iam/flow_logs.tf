resource aws_iam_role flow_logs {
  tags = var.tags
  name = "${var.resource_prefix}-flow-logs"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })
}

resource aws_iam_role_policy_attachment flow_logs_cloudwatch_write {
  role       = aws_iam_role.flow_logs.name
  policy_arn = aws_iam_policy.cloudwatch_logs_write.arn
}
