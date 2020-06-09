terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = join("-", [var.env_name, var.region, var.deployment_id])
  common_environment_variables = {
    CNI_DDB_FANOUT_TOPIC = module.sns_topics.dynamodb_stream_fanout_topic.arn
    CNI_TABLE_PREFIX     = local.resource_prefix
    CNI_ENV              = var.env_name
    CNI_DEPLOYMENT_ID    = var.deployment_id
  }
  api_access_whitelist = "${var.env_name == "prod" ? var.api_prod_access_whitelist : var.api_dev_access_whitelist}"
}

###############################
#  SNS Topics
###############################

module sns_topics {
  source                          = "../modules/sns_topics"
  tags                            = var.tags
  region                          = var.region
  resource_prefix                 = local.resource_prefix
  admin_principals                = data.terraform_remote_state.region_base.outputs.admin_principals
  private_connect_role            = data.terraform_remote_state.stack_base.outputs.iam.private_connect_role
  private_link_event_handler_role = data.terraform_remote_state.stack_base.outputs.iam.private_link_event_handler_role
  private_link_stream_role        = data.terraform_remote_state.stack_base.outputs.iam.private_link_stream_role
}

# Consumed in EKS setup for finishing the inbound config settings creation
resource aws_ssm_parameter inbound_vpce_sns_topic {
  tags        = var.tags
  name        = format("/%s-%s/%s/control-plane/inbound-vpce-sns-topic", var.env_name, var.region, var.deployment_id)
  type        = "SecureString"
  value       = module.sns_topics.inbound_vpce_connections_topic.arn
}

###############################
#  Config Settings Tables
###############################

module config_settings_tables {
  source                          = "../modules/config_settings_tables"
  tags                            = var.tags
  resource_prefix                 = local.resource_prefix
  api_key                         = data.aws_secretsmanager_secret_version.api_key.secret_string
  private_link_access_role        = data.terraform_remote_state.stack_base.outputs.iam.private_connect_role
  outbound_zone                   = data.terraform_remote_state.stack_base.outputs.outbound_dns_zone
  outbound_vpce_connections_topic = module.sns_topics.outbound_vpce_connections_topic
}

###############################
#  Private Link Tables
###############################

module private_link_tables {
  source          = "../modules/private_link_tables"
  tags            = var.tags
  resource_prefix = local.resource_prefix
}

###############################
#  Layer
###############################

resource aws_lambda_layer_version common {
  layer_name  = "${local.resource_prefix}-common"
  s3_bucket   = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket.bucket
  s3_key      = var.lambda_layer_s3_key
  description = var.lambda_layer_s3_key
}

###############################
#  REST API
###############################

module rest_api {
  source                             = "../modules/rest_api"
  tags                               = var.tags
  resource_prefix                    = local.resource_prefix
  api_access_whitelist               = concat(local.api_access_whitelist, var.api_access_whitelist_ips)
  api_authorization                  = var.api_authorization
  api_authorizer_gdot_url            = var.api_authorizer_gdot_url
  api_authorizer_c2c_key_secret_name = var.api_authorizer_c2c_key_secret_name
  artifact_bucket                    = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  lambda_function_s3_key             = var.lambda_function_s3_key
  lambda_runtime                     = var.lambda_runtime
  lambda_memory_size                 = var.lambda_memory_size
  lambda_timeout                     = var.lambda_timeout
  lambda_layer_arns = [
    aws_lambda_layer_version.common.arn
  ]
  environment_variables      = local.common_environment_variables
  authorizer_invocation_role = data.terraform_remote_state.stack_base.outputs.iam.authorizer_invocation_role
  authorizer_role            = data.terraform_remote_state.stack_base.outputs.iam.authorizer_role
  rest_api_endpoint_role     = data.terraform_remote_state.stack_base.outputs.iam.rest_api_endpoint_role
  api_gateway_logs_role      = data.terraform_remote_state.stack_base.outputs.iam.api_gateway_logs_role
}

###############################
#  Supervisor
###############################

module inbound_supervisor {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-in-supervisor"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.supervisor_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.scheduled_supervisor_inbound_handler"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_schedule = true
  schedule     = "rate(1 minute)"
}

module outbound_supervisor {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-out-supervisor"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.supervisor_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.scheduled_supervisor_outbound_handler"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_schedule = true
  schedule     = "rate(1 minute)"
}

module custom_metrics {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-custom-metrics"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.supervisor_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.custom_metrics_update"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_schedule = true
  schedule     = "rate(1 minute)"
}
###############################
#  Private Link Stream
###############################

module inbound_private_link_stream {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-in-pl-stream"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.private_link_stream_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.stream_ddb_inbound_pl_handler"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_event_source = true
  event_source_arn = module.private_link_tables.inbound.stream_arn
}

module outbound_private_link_stream {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-out-pl-stream"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.private_link_stream_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.stream_ddb_outbound_pl_handler"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_event_source = true
  event_source_arn = module.private_link_tables.outbound.stream_arn
}

###############################
#  Private Link Handler
###############################

module inbound_private_link_handler {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-in-pl-event-handler"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.private_link_event_handler_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.sns_private_link_handler_inbound"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_sns_topic = true
  sns_topic_arn = module.sns_topics.inbound_vpce_connections_topic.arn
}

module outbound_private_link_handler {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-out-pl-event-handler"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.private_link_event_handler_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.sns_private_link_handler_outbound"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_sns_topic = true
  sns_topic_arn = module.sns_topics.outbound_vpce_connections_topic.arn
}

###############################
#  DDB Stream Fanout
###############################

module dynamodb_stream_fanout_function {
  source          = "../modules/lambda_function_v2"
  tags            = var.tags
  function_name   = "${local.resource_prefix}-ddb-stream-fanout"
  function_role   = data.terraform_remote_state.stack_base.outputs.iam.private_connect_role
  artifact_bucket = data.terraform_remote_state.region_base.outputs.artifact_bucket.bucket
  s3_key          = var.lambda_function_s3_key
  handler         = "app.sns_ddb_fanout_handler"
  layers = [
    aws_lambda_layer_version.common.arn
  ]
  memory_size                       = var.lambda_memory_size
  environment_variables             = local.common_environment_variables
  timeout                           = var.lambda_timeout
  provisioned_concurrent_executions = var.lambda_provisioned_concurrent_executions

  has_sns_topic = true
  sns_topic_arn = module.sns_topics.dynamodb_stream_fanout_topic.arn
}
