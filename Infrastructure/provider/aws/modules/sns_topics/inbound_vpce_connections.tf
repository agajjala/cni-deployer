module inbound_vpce_connections_kms_key {
  source             = "../kms_key"
  tags               = var.tags
  admin_principals   = var.admin_principals
  source_json_policy = data.aws_iam_policy_document.inbound_vpce_connections_key_lambda_access.json
}

data aws_iam_policy_document inbound_vpce_connections_key_lambda_access {
  source_json = data.aws_iam_policy_document.kms_key_sns_access.json
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt*"
    ]

    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.private_link_event_handler_role.arn
      ]
    }
    resources = [
      "*"
    ]
  }
}

resource aws_sns_topic inbound_vpce_connections {
  name              = local.inbound_vpce_connections_name
  display_name      = local.inbound_vpce_connections_name
  # TODO: Enable KMS encryption

  tags              = var.tags
}

resource aws_sns_topic_policy inbound_vpce_connections {
  arn = aws_sns_topic.inbound_vpce_connections.arn

  policy = data.aws_iam_policy_document.inbound_vpce_connections_publish_access.json
}