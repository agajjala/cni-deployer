module inbound_supervisor {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-supervisor"
  role_arn              = var.inbound_supervisor_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.scheduled_supervisor_inbound_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  timeout               = 300
  environment_variables = local.common_environment_variables
  has_schedule          = true
  schedule              = "rate(1 minute)"

  tags                  = var.tags
}

module inbound_private_link_stream {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-stream"
  role_arn              = var.inbound_private_link_stream_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.stream_ddb_inbound_pl_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  timeout               = 60
  environment_variables = local.common_environment_variables
  has_event_source      = true
  event_source_arn      = var.inbound_private_link_stream_arn

  tags                  = var.tags
}

module inbound_private_link_info {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-info"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.api_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_update {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-update"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.api_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_delete {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-delete"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.api_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_get {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-get"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.api_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}

module inbound_private_link_get_one {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-in-pl-get-one"
  role_arn              = var.inbound_private_link_api_endpoint_role_arn
  s3_bucket             = var.s3_bucket
  s3_key                = var.s3_key
  handler               = "app.api_handler"
  layers                = var.layers
  memory_size           = var.memory_size
  environment_variables = local.common_environment_variables

  tags                  = var.tags
}
