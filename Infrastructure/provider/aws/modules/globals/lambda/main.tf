locals {
  # TODO: investigate why each of these is required across all lambdas
  common_environment_variables = {
    CNI_TABLE_PREFIX     = var.resource_prefix
    CNI_DDB_FANOUT_TOPIC = var.dynamodb_stream_fanout_topic_arn
  }
  common_layers = [
    aws_lambda_layer_version.common.arn
  ]
}

resource aws_lambda_layer_version common {
  layer_name        = "${var.resource_prefix}-common"
  s3_bucket         = var.bucket_name
  s3_key            = var.layer_s3_key
  s3_object_version = var.layer_s3_object_version == "" ? null : var.layer_s3_object_version
}

module dynamodb_stream_fanout {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-ddb-stream-fanout"
  role_arn              = var.dynamodb_stream_fanout_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.sns_ddb_fanout_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_sns_topic         = true
  sns_topic_arn         = var.dynamodb_stream_fanout_topic_arn

  tags                  = var.tags
}

###############################
#  IAM Policy for SNS KMS key
###############################

data aws_iam_policy_document dynamodb_stream_fanout_sns_kms_key_access {
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt*"
    ]

    effect = "Allow"

    resources = [
      var.dynamodb_stream_fanout_kms_key_arn
    ]
  }
}

resource aws_iam_policy dynamodb_stream_fanout_sns_kms_key_access {
  name   = "${var.resource_prefix}-ddb-stream-fanout-sns-kms"
  policy = data.aws_iam_policy_document.dynamodb_stream_fanout_sns_kms_key_access.json
}

resource aws_iam_role_policy_attachment dynamodb_stream_fanout_sns_kms_key_access {
  policy_arn = aws_iam_policy.dynamodb_stream_fanout_sns_kms_key_access.arn
  role       = var.dynamodb_stream_fanout_role_name
}
