resource aws_iam_role inbound_private_link_event_handler {
  name = "${var.resource_prefix}-in-pl-event-handler"

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

resource aws_iam_role_policy_attachment inbound_private_link_event_handler_lambda_basic_execution {
  role       = aws_iam_role.inbound_private_link_event_handler.name
  policy_arn = local.lambda_basic_execution_role_arn
}

resource aws_iam_role_policy_attachment inbound_private_link_event_handler_xray_access {
  role       = aws_iam_role.inbound_private_link_event_handler.name
  policy_arn = local.xray_write_access_arn
}

resource aws_iam_role_policy_attachment inbound_private_link_event_handler_dynamodb_read_write_access {
  role       = aws_iam_role.inbound_private_link_event_handler.name
  policy_arn = aws_iam_policy.dynamodb_read_write_access.arn
}

resource aws_iam_role_policy_attachment inbound_private_link_event_handler_private_link_limited_access {
  role       = aws_iam_role.inbound_private_link_event_handler.name
  policy_arn = aws_iam_policy.private_link_limited_access.arn
}
