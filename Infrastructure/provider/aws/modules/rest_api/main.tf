locals {
  stage_name = "default"
  rest_api_access_policy = jsonencode({
    Statement = [
      {
        Action    = "execute-api:Invoke"
        Effect    = "Allow"
        Principal = "*"
        Resource  = "execute-api:/*/*/*"
      },
      {
        Action = "execute-api:Invoke"
        Condition = {
          NotIpAddress = {
            "aws:SourceIp" = var.api_access_whitelist
          }
        }
        Effect    = "Deny"
        Principal = "*"
        Resource  = "execute-api:/*/*/*"
      },
    ]
    Version = "2012-10-17"
  })
}

resource aws_api_gateway_rest_api api {
  name   = var.resource_prefix
  tags   = var.tags
  policy = local.rest_api_access_policy
}

module rest_api_v1 {
  source                            = "../rest_api_v1"
  resource_prefix                   = var.resource_prefix
  tags                              = var.tags
  rest_api                          = aws_api_gateway_rest_api.api
  authorization                     = var.api_authorization
  gdot_url                          = var.api_authorizer_gdot_url
  c2c_key_secret_name               = var.api_authorizer_c2c_key_secret_name
  stage_name                        = local.stage_name
  artifact_bucket                   = var.artifact_bucket
  s3_key                            = var.lambda_function_s3_key
  runtime                           = var.lambda_runtime
  memory_size                       = var.lambda_memory_size
  layers                            = var.lambda_layer_arns
  timeout                           = var.lambda_timeout
  environment_variables             = var.environment_variables
  provisioned_concurrent_executions = var.provisioned_concurrent_executions
  authorizer_invocation_role        = var.authorizer_invocation_role
  authorizer_role                   = var.authorizer_role
  rest_api_endpoint_role            = var.rest_api_endpoint_role
}

resource aws_api_gateway_deployment deployment {
  rest_api_id = aws_api_gateway_rest_api.api.id

  variables = {
    deployment_hash = sha1(join(",", [
      local.rest_api_access_policy,
      module.rest_api_v1.resource_hash
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource aws_api_gateway_stage stage {
  stage_name    = local.stage_name
  rest_api_id   = aws_api_gateway_rest_api.api.id
  deployment_id = aws_api_gateway_deployment.deployment.id
  xray_tracing_enabled = true
}

resource aws_api_gateway_method_settings settings {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.stage.stage_name
  method_path = "*/*"
  settings {
    logging_level      = "INFO"
    data_trace_enabled = true
    metrics_enabled    = true
  }
}
