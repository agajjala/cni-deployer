data aws_iam_policy_document default {
  source_json = var.source_json
  statement {
    actions = [
      "kms:*"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.admin_role_arn
      ]
    }
    resources = [
      "*"
    ]
  }
  version = "2012-10-17"
}

resource aws_kms_key default {
  description         = var.key_name
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.default.json
  tags                = var.tags
}

resource aws_kms_alias default {
  name          = "alias/${var.key_name}"
  target_key_id = aws_kms_key.default.id
}
