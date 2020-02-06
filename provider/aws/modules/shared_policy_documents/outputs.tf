output kms_key_cloudwatch_access_json {
  value = data.aws_iam_policy_document.kms_key_cloudwatch_access.json
}
