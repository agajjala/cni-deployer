###############################
#  API Gateway Invocation Role
###############################

resource aws_iam_role authorizer_invocation {
  tags = var.tags
  name = "${var.resource_prefix}-auth-invocation"
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
#  Lambda Role
###############################

resource aws_iam_role authorizer {
  tags = var.tags
  name = "${var.resource_prefix}-auth"
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

resource aws_iam_role_policy_attachment authorizer_lambda_basic_execution {
  role       = aws_iam_role.authorizer.name
  policy_arn = local.lambda_basic_execution_role_policy_arn
}

resource aws_iam_role_policy_attachment authorizer_xray_access {
  role       = aws_iam_role.authorizer.name
  policy_arn = local.xray_write_policy_arn
}

resource aws_iam_role_policy_attachment authorizer_dynamodb_read_write {
  role       = aws_iam_role.authorizer.name
  policy_arn = aws_iam_policy.dynamodb_read_write.arn
}

resource aws_iam_role_policy_attachment authorizer_secret_read {
  role       = aws_iam_role.authorizer.name
  policy_arn = aws_iam_policy.authorizer_secret_read.arn
}

resource aws_iam_role_policy_attachment authorizer_attach_eip {
  role = aws_iam_role.authorizer.name
  policy_arn = aws_iam_policy.attach_eip.arn
}

resource aws_iam_policy authorizer_secret_read {
  name   = "${var.resource_prefix}-auth-secret-r"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement: [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds"
        ]
        Resource = formatlist("arn:aws:secretsmanager:%s:${data.aws_caller_identity.current.account_id}:secret:${var.resource_prefix}*-c2c-ec-key", [var.region])
      }
    ]
  })
}
