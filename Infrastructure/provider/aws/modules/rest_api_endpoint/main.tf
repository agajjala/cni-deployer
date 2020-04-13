locals {
  # Lambdas can only be invoked using a POST request: https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html
  integration_http_method = "POST"
}

module endpoint_function {
  source                            = "../lambda_function_v2"
  tags                              = var.tags
  function_name                     = var.function_name
  function_role                     = var.function_role
  artifact_bucket                   = var.artifact_bucket
  s3_key                            = var.s3_key
  runtime                           = var.runtime
  handler                           = var.handler
  memory_size                       = var.memory_size
  layers                            = var.layers
  timeout                           = var.timeout
  environment_variables             = var.environment_variables
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}

resource aws_api_gateway_method method {
  rest_api_id   = var.rest_api.id
  resource_id   = var.resource.id
  http_method   = var.http_method
  authorization = var.authorization
  authorizer_id = var.authorizer_id
}

resource aws_api_gateway_integration integration {
  rest_api_id             = var.rest_api.id
  resource_id             = var.resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = local.integration_http_method
  type                    = "AWS_PROXY"
  uri                     = module.endpoint_function.lambda_function.invoke_arn
}

resource aws_lambda_permission permission {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.endpoint_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.rest_api.execution_arn}/*/${aws_api_gateway_method.method.http_method}${var.resource.path}"
}
