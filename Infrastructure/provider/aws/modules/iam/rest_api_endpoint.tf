resource aws_iam_role rest_api_endpoint {
  tags = var.tags
  name = "${var.resource_prefix}-rest-api-endpoint"
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

resource aws_iam_role_policy_attachment rest_api_endpoint_lambda_basic_execution {
  role       = aws_iam_role.rest_api_endpoint.name
  policy_arn = local.lambda_basic_execution_role_policy_arn
}

resource aws_iam_role_policy_attachment rest_api_endpoint_xray_write {
  role       = aws_iam_role.rest_api_endpoint.name
  policy_arn = local.xray_write_policy_arn
}

resource aws_iam_role_policy_attachment rest_api_endpoint_dynamodb_read_write {
  role       = aws_iam_role.rest_api_endpoint.name
  policy_arn = aws_iam_policy.dynamodb_read_write.arn
}

resource aws_iam_role_policy_attachment rest_api_endpoint_route53_read_write {
  role       = aws_iam_role.rest_api_endpoint.name
  policy_arn = aws_iam_policy.route53_read_write.arn
}
