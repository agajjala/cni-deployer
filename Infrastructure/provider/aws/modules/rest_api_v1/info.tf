###############################
#  /info
###############################

resource aws_api_gateway_resource info {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.api_version.id
  path_part   = "info"
}

###############################
#  /info/inbound
###############################

resource aws_api_gateway_resource info_inbound {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.info.id
  path_part   = "inbound"
}

module info_inbound_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.info_inbound
  http_method = "GET"
  function_name = "${var.resource_prefix}-info-inbound-GET"
  tags = var.tags
  rest_api = var.rest_api
  authorization = var.authorization
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
  function_role = var.rest_api_endpoint_role
  artifact_bucket = var.artifact_bucket
  s3_key = var.s3_key
  runtime = var.runtime
  handler = local.api_lambda_function_handler
  memory_size = var.memory_size
  layers = var.layers
  timeout = var.timeout
  environment_variables = var.environment_variables
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}

###############################
#  /info/outbound
###############################

resource aws_api_gateway_resource info_outbound {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.info.id
  path_part   = "outbound"
}

module info_outbound_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.info_outbound
  http_method = "GET"
  function_name = "${var.resource_prefix}-info-outbound-GET"
  tags = var.tags
  rest_api = var.rest_api
  authorization = var.authorization
  authorizer_id = aws_api_gateway_authorizer.authorizer.id
  function_role = var.rest_api_endpoint_role
  artifact_bucket = var.artifact_bucket
  s3_key = var.s3_key
  runtime = var.runtime
  handler = local.api_lambda_function_handler
  memory_size = var.memory_size
  layers = var.layers
  timeout = var.timeout
  environment_variables = var.environment_variables
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}
