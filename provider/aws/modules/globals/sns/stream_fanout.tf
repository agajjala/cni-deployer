module stream_fanout_key {
  source         = "../../kms_key"
  tags           = var.tags
  key_name       = local.stream_fanout_name
  admin_role_arn = var.admin_role_arn
  source_json    = data.aws_iam_policy_document.kms_key_sns_access.json
}

resource aws_sns_topic stream_fanout {
  name              = local.stream_fanout_name
  display_name      = local.stream_fanout_name
  kms_master_key_id = module.stream_fanout_key.key_id

  tags              = var.tags
}
