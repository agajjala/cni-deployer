module dynamodb_stream_fanout_kms_key {
  source             = "../kms_key"
  tags               = var.tags
  admin_role_arns     = var.admin_role_arns
  source_json_policy = data.aws_iam_policy_document.kms_key_sns_access.json
}

resource aws_sns_topic dynamodb_stream_fanout {
  name              = local.stream_fanout_name
  display_name      = local.stream_fanout_name
  # TODO: Enable KMS encryption

  tags              = var.tags
}
