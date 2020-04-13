output resource_hash {
  value = sha1(join(",", [
    jsonencode(aws_api_gateway_method.method),
    jsonencode(aws_api_gateway_integration.integration),
    jsonencode(aws_lambda_permission.permission),
    module.endpoint_function.resource_hash
  ]))
}
