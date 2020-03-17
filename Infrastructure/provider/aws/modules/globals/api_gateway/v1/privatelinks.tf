###############################
#  /privatelinks
###############################

resource aws_api_gateway_resource privatelinks {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.api_version.id
  path_part   = "privatelinks"
}

###############################
#  /privatelinks/inbound
###############################

resource aws_api_gateway_resource privatelinks_inbound {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.privatelinks.id
  path_part   = "inbound"
}

module privatelinks_inbound_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_inbound.id
  http_method   = "GET"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_inbound.path
  invoke_arn    = var.privatelinks_inbound_get_lambda.invoke_arn
  function_name = var.privatelinks_inbound_get_lambda.function_name
}

###############################
#  /privatelinks/inbound/{privatelink_id}
###############################

resource aws_api_gateway_resource privatelinks_inbound_item {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.privatelinks_inbound.id
  path_part   = "{privatelink_id}"
}

module privatelinks_inbound_item_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_inbound_item.id
  http_method   = "GET"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_inbound_item.path
  invoke_arn    = var.privatelinks_inbound_get_one_lambda.invoke_arn
  function_name = var.privatelinks_inbound_get_one_lambda.function_name
}

module privatelinks_inbound_item_update {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_inbound_item.id
  http_method   = "PUT"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_inbound_item.path
  invoke_arn    = var.privatelinks_inbound_update_lambda.invoke_arn
  function_name = var.privatelinks_inbound_update_lambda.function_name
}

module privatelinks_inbound_item_delete {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_inbound_item.id
  http_method   = "DELETE"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_inbound_item.path
  invoke_arn    = var.privatelinks_inbound_delete_lambda.invoke_arn
  function_name = var.privatelinks_inbound_delete_lambda.function_name
}

module privatelinks_inbound_item_retry {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_inbound_item.id
  http_method   = "PATCH"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_inbound_item.path
  invoke_arn    = var.privatelinks_inbound_retry_lambda.invoke_arn
  function_name = var.privatelinks_inbound_retry_lambda.function_name
}

###############################
#  /privatelinks/outbound
###############################

resource aws_api_gateway_resource privatelinks_outbound {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.privatelinks.id
  path_part   = "outbound"
}

module privatelinks_outbound_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound.id
  http_method   = "GET"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound.path
  invoke_arn    = var.privatelinks_outbound_get_lambda.invoke_arn
  function_name = var.privatelinks_outbound_get_lambda.function_name
}

module privatelinks_outbound_create {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound.id
  http_method   = "POST"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound.path
  invoke_arn    = var.privatelinks_outbound_create_lambda.invoke_arn
  function_name = var.privatelinks_outbound_create_lambda.function_name
}

###############################
#  /privatelinks/outbound/{privatelink_id}
###############################

resource aws_api_gateway_resource privatelinks_outbound_item {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.privatelinks_outbound.id
  path_part   = "{privatelink_id}"
}

module privatelinks_outbound_item_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound_item.id
  http_method   = "GET"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound_item.path
  invoke_arn    = var.privatelinks_outbound_get_one_lambda.invoke_arn
  function_name = var.privatelinks_outbound_get_one_lambda.function_name
}

module privatelinks_outbound_item_update {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound_item.id
  http_method   = "PUT"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound_item.path
  invoke_arn    = var.privatelinks_outbound_update_lambda.invoke_arn
  function_name = var.privatelinks_outbound_update_lambda.function_name
}

module privatelinks_outbound_item_delete {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound_item.id
  http_method   = "DELETE"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound_item.path
  invoke_arn    = var.privatelinks_outbound_delete_lambda.invoke_arn
  function_name = var.privatelinks_outbound_delete_lambda.function_name
}

module privatelinks_outbound_item_retry {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.privatelinks_outbound_item.id
  http_method   = "PATCH"
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.privatelinks_outbound_item.path
  invoke_arn    = var.privatelinks_outbound_retry_lambda.invoke_arn
  function_name = var.privatelinks_outbound_retry_lambda.function_name
}
