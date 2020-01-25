data aws_iam_policy_document flow_logs_key_cloudwatch_access {
  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.amazonaws.com"
      ]
    }
    resources = [
      "*"
    ]
  }
}
