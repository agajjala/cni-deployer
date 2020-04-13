###############################
#  /privatelinks
###############################

resource aws_api_gateway_resource privatelinks {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.api_version.id
  path_part   = "privatelinks"
}

###############################
#  /privatelinks/inbound
###############################

resource aws_api_gateway_resource privatelinks_inbound {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.privatelinks.id
  path_part   = "inbound"
}

module privatelinks_inbound_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_inbound
  http_method = "GET"
  function_name = "${var.resource_prefix}-pl-inbound-get"
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

##############################################################
#  /privatelinks/inbound/{privatelink_id}
##############################################################

resource aws_api_gateway_resource privatelinks_inbound_item {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.privatelinks_inbound.id
  path_part   = "{privatelink_id}"
}

module privatelinks_inbound_item_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_inbound_item
  http_method = "GET"
  function_name = "${var.resource_prefix}-pl-inbound-item-GET"
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

module privatelinks_inbound_item_put {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_inbound_item
  http_method = "PUT"
  function_name = "${var.resource_prefix}-pl-inbound-item-PUT"
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

module privatelinks_inbound_item_delete {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_inbound_item
  http_method = "DELETE"
  function_name = "${var.resource_prefix}-pl-inbound-item-DELETE"
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

module privatelinks_inbound_item_patch {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_inbound_item
  http_method = "PATCH"
  function_name = "${var.resource_prefix}-pl-inbound-item-PATCH"
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
#  /privatelinks/outbound
###############################

resource aws_api_gateway_resource privatelinks_outbound {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.privatelinks.id
  path_part   = "outbound"
}

module privatelinks_outbound_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound
  http_method = "GET"
  function_name = "${var.resource_prefix}-pl-outbound-GET"
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

module privatelinks_outbound_post {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound
  http_method = "POST"
  function_name = "${var.resource_prefix}-pl-outbound-POST"
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

##############################################################
#  /privatelinks/outbound/{privatelink_id}
##############################################################

resource aws_api_gateway_resource privatelinks_outbound_item {
  rest_api_id = var.rest_api.id
  parent_id   = aws_api_gateway_resource.privatelinks_outbound.id
  path_part   = "{privatelink_id}"
}

module privatelinks_outbound_item_get {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound_item
  http_method = "GET"
  function_name = "${var.resource_prefix}-pl-outbound-item-GET"
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

module privatelinks_outbound_item_put {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound_item
  http_method = "PUT"
  function_name = "${var.resource_prefix}-pl-outbound-item-PUT"
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

module privatelinks_outbound_item_delete {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound_item
  http_method = "DELETE"
  function_name = "${var.resource_prefix}-pl-outbound-item-DELETE"
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

module privatelinks_outbound_item_patch {
  source = "../rest_api_endpoint"
  resource = aws_api_gateway_resource.privatelinks_outbound_item
  http_method = "PATCH"
  function_name = "${var.resource_prefix}-pl-outbound-item-PATCH"
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
