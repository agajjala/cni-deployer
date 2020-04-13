output resource_hash {
  value = sha1(join(",", [
    jsonencode(aws_lambda_function.function),
    jsonencode(aws_lambda_alias.alias),
    jsonencode(aws_lambda_provisioned_concurrency_config.config.*)
  ]))
}

output lambda_function {
  value = aws_lambda_function.function
}

output lambda_alias {
  value = aws_lambda_alias.alias
}
