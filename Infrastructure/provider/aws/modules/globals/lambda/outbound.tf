module outbound_private_link_event_handler {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-event-handler"
  role_arn              = var.outbound_private_link_event_handler_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.sns_private_link_handler_outbound"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_sns_topic         = true
  sns_topic_arn         = var.outbound_vpce_connections_topic_arn

  tags                  = var.tags
}

module outbound_supervisor_fn {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-supervisor"
  role_arn              = var.outbound_supervisor_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.scheduled_supervisor_outbound_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_schedule          = true
  schedule              = "rate(1 minute)"

  tags                  = var.tags
}

module outbound_private_link_stream {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-stream"
  role_arn              = var.outbound_private_link_stream_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.stream_ddb_outbound_pl_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables
  has_event_source      = true
  event_source_arn      = var.outbound_private_link_stream_arn

  tags                  = var.tags
}

###############################
#  IAM Policy for SNS KMS key
###############################

data aws_iam_policy_document outbound_private_link_stream_sns_kms_key_access {
  statement {
    actions = [
      "kms:GenerateDataKey",
      "kms:Decrypt*"
    ]

    effect = "Allow"

    resources = [
      var.outbound_vpce_connections_kms_key_arn
    ]
  }
}

resource aws_iam_policy outbound_private_link_stream_sns_kms_key_access {
  name   = "${var.resource_prefix}-out-pl-stream-sns-kms"
  policy = data.aws_iam_policy_document.outbound_private_link_stream_sns_kms_key_access.json
}

resource aws_iam_role_policy_attachment outbound_private_link_stream_sns_kms_key_access {
  policy_arn = aws_iam_policy.outbound_private_link_stream_sns_kms_key_access.arn
  role       = var.outbound_private_link_stream_role_name
}

module outbound_private_link_info {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-info"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module outbound_private_link_create {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-create"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module outbound_private_link_delete {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-delete"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module outbound_private_link_update {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-update"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module outbound_private_link_get {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-get"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module outbound_private_link_get_one {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-get-one"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.bucket_name
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}
