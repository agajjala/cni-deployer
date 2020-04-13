module outbound_vpce_connections_key {
  source             = "../../kms_key"
  tags               = var.tags
  admin_role_arns     = var.admin_role_arns
  source_json_policy = data.aws_iam_policy_document.outbound_vpce_connections_key_lambda_access.json
}

data aws_iam_policy_document outbound_vpce_connections_key_lambda_access {
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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-out-pl-event-handler",
      ]
    }
    resources = [
      "*"
    ]
  }
}

resource aws_sns_topic outbound_vpce_connections {
  name              = local.outbound_vpce_connections_name
  display_name      = local.outbound_vpce_connections_name
//  kms_master_key_id = module.outbound_vpce_connections_key.key_id

  tags              = var.tags
}

resource aws_sns_topic_policy vpce_connections {
  arn = aws_sns_topic.outbound_vpce_connections.arn

  policy = data.aws_iam_policy_document.outbound_vpce_connections_publish_access.json
}