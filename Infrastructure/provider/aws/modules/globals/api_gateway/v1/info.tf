###############################
#  /info
###############################

resource aws_api_gateway_resource info {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.api_version.id
  path_part   = "info"
}

###############################
#  /info/inbound
###############################

resource aws_api_gateway_resource info_inbound {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.info.id
  path_part   = "inbound"
}

module info_inbound_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.info_inbound.id
  http_method   = "GET"
  authorizer_id = var.authorizer_id
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.info_inbound.path
  invoke_arn    = var.info_inbound_get_lambda.invoke_arn
  function_name = var.info_inbound_get_lambda.function_name
}

###############################
#  /info/outbound
###############################

resource aws_api_gateway_resource info_outbound {
  rest_api_id = var.api_id
  parent_id   = aws_api_gateway_resource.info.id
  path_part   = "outbound"
}

module info_outbound_get {
  source        = "../../../api_gateway_rest_lambda_endpoint"
  api_id        = var.api_id
  resource_id   = aws_api_gateway_resource.info_outbound.id
  http_method   = "GET"
  authorizer_id = var.authorizer_id
  execution_arn = var.execution_arn
  endpoint_path = aws_api_gateway_resource.info_outbound.path
  invoke_arn    = var.info_outbound_get_lambda.invoke_arn
  function_name = var.info_outbound_get_lambda.function_name
}
