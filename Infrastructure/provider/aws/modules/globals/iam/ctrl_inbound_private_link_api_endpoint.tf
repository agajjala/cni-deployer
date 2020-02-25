resource aws_iam_role inbound_private_link_api_endpoint {
  name = "${var.resource_prefix}-in-pl-api-endpoint"

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

resource aws_iam_role_policy_attachment inbound_private_link_api_endpoint_xray_write_access {
  role       = aws_iam_role.inbound_private_link_api_endpoint.name
  policy_arn = local.xray_write_access_arn
}

resource aws_iam_role_policy_attachment inbound_private_link_api_endpoint_dynamodb_read_write_access {
  role       = aws_iam_role.inbound_private_link_api_endpoint.name
  policy_arn = aws_iam_policy.inbound_dynamodb_read_write_access.arn
}
