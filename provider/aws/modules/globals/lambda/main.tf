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
  s3_bucket         = var.artifact_bucket
  s3_key            = var.layer_s3_key
  s3_object_version = var.layer_s3_object_version == "$LATEST" ? null : var.layer_s3_object_version
}


module dynamodb_stream_fanout {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-ddb-stream-fanout"
  role_arn              = var.dynamodb_stream_fanout_role_arn
  s3_bucket             = var.artifact_bucket
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.sns_ddb_fanout_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  timeout               = 60
  environment_variables = local.common_environment_variables
  has_sns_topic         = true
  sns_topic_arn         = var.dynamodb_stream_fanout_topic_arn

  tags                  = var.tags
}

module private_link_event_handler {
  source                = "../../../modules/lambda_function"
  function_name         = "${var.resource_prefix}-pl-event-handler"
  role_arn              = var.private_link_event_handler_role_arn
  s3_bucket             = var.artifact_bucket
  s3_key                = var.function_s3_key
  s3_object_version     = var.function_s3_object_version
  handler               = "app.sns_private_link_handler"
  layers                = local.common_layers
  memory_size           = var.memory_size
  timeout               = 60
  environment_variables = local.common_environment_variables
  has_sns_topic         = true
  sns_topic_arn         = var.vpce_connections_topic_arn

  tags                  = var.tags
}
