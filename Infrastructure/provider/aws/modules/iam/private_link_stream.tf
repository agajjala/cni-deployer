resource aws_iam_role private_link_stream {
  tags = var.tags
  name = "${var.resource_prefix}-pl-stream"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource aws_iam_role_policy_attachment private_link_stream_lambda_basic_execution {
  role       = aws_iam_role.private_link_stream.name
  policy_arn = local.lambda_basic_execution_role_policy_arn
}

resource aws_iam_role_policy_attachment private_link_stream_xray_write {
  role       = aws_iam_role.private_link_stream.name
  policy_arn = local.xray_write_policy_arn
}

resource aws_iam_role_policy_attachment private_link_stream_dynamodb_stream_read {
  role       = aws_iam_role.private_link_stream.name
  policy_arn = local.lambda_dynamodb_stream_read_policy_arn
}

resource aws_iam_role_policy_attachment private_link_stream_dynamodb_read_write {
  role       = aws_iam_role.private_link_stream.name
  policy_arn = aws_iam_policy.dynamodb_read_write.arn
}

resource aws_iam_role_policy_attachment private_link_stream_sns_write {
  role       = aws_iam_role.private_link_stream.name
  policy_arn = aws_iam_policy.sns_write.arn
}