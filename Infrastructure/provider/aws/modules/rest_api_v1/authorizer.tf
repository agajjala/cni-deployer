module authorizer_function {
  source = "../lambda_function_v2"
  tags = var.tags
  function_name = "${var.resource_prefix}-authorizer"
  function_role = var.authorizer_role
  artifact_bucket = var.artifact_bucket
  s3_key = var.s3_key
  runtime = var.runtime
  handler = "app.authorization_handler"
  memory_size = var.memory_size
  layers = var.layers
  timeout = var.timeout
  environment_variables = merge(var.environment_variables, {
    CHECK_API_KEY = "True"
    GDOT_URL = var.gdot_url
    SECRET_NAME = var.c2c_key_secret_name
    AWS_ACCOUNT_ID = data.aws_caller_identity.current.account_id
    REST_API_ID = var.rest_api.id
    STAGE = var.stage_name
  })
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
}

resource aws_api_gateway_authorizer authorizer {
  name                   = "${var.resource_prefix}-authorizer"
  rest_api_id            = var.rest_api.id
  type                   = "REQUEST"
  identity_source        = "method.request.header.Authorization"
  authorizer_uri         = module.authorizer_function.lambda_function.invoke_arn
  authorizer_result_ttl_in_seconds = 0

  lifecycle {
    # Manual changes to identity source via UI or CLI will be ignored
    ignore_changes = ["identity_source"]
  }
}

resource aws_lambda_permission authorizer {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = module.authorizer_function.lambda_function.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = format("%s/authorizers/%s", var.rest_api.execution_arn, aws_api_gateway_authorizer.authorizer.id)
}
