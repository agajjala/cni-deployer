module inbound_private_link_event_handler {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-event-handler"
  role_arn              = var.inbound_private_link_event_handler_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.sns_private_link_handler_inbound"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_sns_topic         = true
  sns_topic_arn         = var.inbound_vpce_connections_topic_arn

  tags                  = var.tags
}

module inbound_supervisor {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-supervisor"
  role_arn              = var.inbound_supervisor_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.scheduled_supervisor_inbound_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_schedule          = true
  schedule              = "rate(1 minute)"

  tags                  = var.tags
}

module inbound_private_link_stream {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-stream"
  role_arn              = var.inbound_private_link_stream_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.stream_ddb_inbound_pl_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_event_source      = true
  event_source_arn      = var.inbound_private_link_stream_arn

  tags                  = var.tags
}

###############################
#  IAM Policy for SNS KMS key
###############################

data aws_iam_policy_document inbound_private_link_stream_sns_kms_key_access {
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt*"
    ]

    effect = "Allow"

    resources = [
      var.inbound_vpce_connections_kms_key_arn
    ]
  }
}

resource aws_iam_policy inbound_private_link_stream_sns_kms_key_access {
  name   = "${var.resource_prefix}-in-pl-stream-sns-kms"
  policy = data.aws_iam_policy_document.inbound_private_link_stream_sns_kms_key_access.json
}

resource aws_iam_role_policy_attachment inbound_private_link_stream_sns_kms_key_access {
  policy_arn = aws_iam_policy.inbound_private_link_stream_sns_kms_key_access.arn
  role       = var.inbound_private_link_stream_role_name
}

module inbound_private_link_info {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-info"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_update {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-update"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_delete {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-delete"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_get {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-get"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_get_one {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-get-one"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_retry {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-retry"
  role_arn              = var.dynamodb_stream_fanout_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}
