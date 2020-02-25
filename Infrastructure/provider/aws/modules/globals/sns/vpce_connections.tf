module vpce_connections_key {
  source             = "../../kms_key"
  tags               = var.tags
  admin_role_arn     = var.admin_role_arn
  source_json_policy = data.aws_iam_policy_document.kms_key_sns_access.json
}

resource aws_sns_topic vpce_connections {
  name              = local.vpce_connections_name
  display_name      = local.vpce_connections_name
  kms_master_key_id = module.vpce_connections_key.key_id

  tags              = var.tags
}

resource aws_sns_topic_policy vpce_connections {
  arn = aws_sns_topic.vpce_connections.arn

  policy = data.aws_iam_policy_document.vpce_connections_publish_access.json
}
