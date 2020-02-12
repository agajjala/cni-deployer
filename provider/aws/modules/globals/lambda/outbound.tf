module outbound_supervisor_fn {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-supervisor"
  role_arn              = var.outbound_supervisor_role_arn
  s3_bucket             = var.artifact_bucket
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.scheduled_supervisor_outbound_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  timeout               = 300
  environment_variables = local.common_environment_variables
  has_schedule          = true
  schedule              = "rate(1 minute)"

  tags                  = var.tags
}

module outbound_private_link_stream {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-stream"
  role_arn              = var.outbound_private_link_stream_role_arn
  s3_bucket             = var.artifact_bucket
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.stream_ddb_outbound_pl_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  timeout               = 60
  environment_variables = local.common_environment_variables
  has_event_source      = true
  event_source_arn      = var.outbound_private_link_stream_arn

  tags                  = var.tags
}

module outbound_private_link_info {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-out-pl-info"
  role_arn              = var.outbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.artifact_bucket
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
  s3_bucket             = var.artifact_bucket
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
  s3_bucket             = var.artifact_bucket
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
  s3_bucket             = var.artifact_bucket
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
  s3_bucket             = var.artifact_bucket
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
  s3_bucket             = var.artifact_bucket
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.api_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}
