variable api_id {}
variable resource_id {}
variable http_method {}
variable execution_arn {}
variable endpoint_path {}
variable invoke_arn {}
variable function_name {}
variable integration_http_method {
  # Lambdas can only be invoked using a POST request: https://docs.aws.amazon.com/lambda/latest/dg/API_Invoke.html
  default = "POST"
}
