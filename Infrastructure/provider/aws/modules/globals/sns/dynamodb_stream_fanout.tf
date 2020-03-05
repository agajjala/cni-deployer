module dynamodb_stream_fanout_key {
  source             = "../../kms_key"
  tags               = var.tags
  admin_role_arn     = var.admin_role_arn
  source_json_policy = data.aws_iam_policy_document.dynamodb_stream_fanout_key_lambda_access.json
}

data aws_iam_policy_document dynamodb_stream_fanout_key_lambda_access {
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
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-ddb-stream-fanout",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-in-pl-stream",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-out-pl-stream",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-in-pl-event-handler",
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.resource_prefix}-out-pl-event-handler"
      ]
    }
    resources = [
      "*"
    ]
  }
}

resource aws_sns_topic dynamodb_stream_fanout {
  name              = local.stream_fanout_name
  display_name      = local.stream_fanout_name
//  kms_master_key_id = module.dynamodb_stream_fanout_key.key_id

  tags              = var.tags
}
