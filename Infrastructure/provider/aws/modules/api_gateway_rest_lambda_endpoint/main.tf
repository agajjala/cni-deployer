resource aws_api_gateway_method method {
  rest_api_id   = var.api_id
  resource_id   = var.resource_id
  http_method   = var.http_method
  authorization = var.authorizer_id == "" ? "NONE" : "CUSTOM"
  authorizer_id = var.authorizer_id == "" ? null : var.authorizer_id
}

resource aws_api_gateway_integration integration {
  rest_api_id             = var.api_id
  resource_id             = var.resource_id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = var.integration_http_method
  type                    = "AWS_PROXY"
  uri                     = var.invoke_arn
}

resource aws_lambda_permission permission {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${var.execution_arn}/*/${aws_api_gateway_method.method.http_method}${var.endpoint_path}"
}
