data aws_iam_policy_document kms_key_sns_access {
  statement {
    actions = [
      "kms:Decrypt*",
      "kms:GenerateDataKey*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "sns.amazonaws.com"
      ]
    }
    resources = [
      "*"
    ]
  }
}

data aws_iam_policy_document vpce_connections_publish_access {
  statement {
    actions = [
      "SNS:Publish"
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpce.amazonaws.com"]
    }

    resources = [
      aws_sns_topic.vpce_connections.arn
    ]
  }
}