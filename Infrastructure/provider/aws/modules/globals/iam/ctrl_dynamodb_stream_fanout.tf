resource aws_iam_role dynamodb_stream_fanout {
  name = "${var.resource_prefix}-ddb-stream-fanout"

  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/PCSKPermissionsBoundary"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF

  tags = var.tags
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_lambda_basic_execution {
  role       = aws_iam_role.dynamodb_stream_fanout.name
  policy_arn = local.lambda_basic_execution_role_arn
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_xray_access {
  role       = aws_iam_role.dynamodb_stream_fanout.name
  policy_arn = local.xray_write_access_arn
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_private_link_access {
  role       = aws_iam_role.dynamodb_stream_fanout.name
  policy_arn = aws_iam_policy.private_link_access.arn
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_route53_read_write_access {
  role       = aws_iam_role.dynamodb_stream_fanout.name
  policy_arn = aws_iam_policy.route53_read_write_access.arn
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_dynamodb_read_write_access {
  role       = aws_iam_role.dynamodb_stream_fanout.name
  policy_arn = aws_iam_policy.dynamodb_read_write_access.arn
}