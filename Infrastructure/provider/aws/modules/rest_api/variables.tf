variable resource_prefix {}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable api_access_whitelist {
  description = "List of CIDRs to whitelist network traffic to the control plane API Gateway"
  type        = list(string)
}
variable api_authorization {
  description = "Type of API Gateway authorization to use"
  type        = string
  default     = "CUSTOM"
}
variable api_authorizer_gdot_url {
  description = "URL of the GDOT endpoint to use for the API Gateway authorizer"
  type        = string
}
variable api_authorizer_c2c_key_secret_name {
  description = "Name of the C2C key secret in Secrets Manager"
  type        = string
}
variable artifact_bucket {
  description = "Bucket containing code artifacts"
  type = object({
    bucket = string
  })
}
variable lambda_function_s3_key {
  description = "Path to the function artifact in the S3 bucket"
  type        = string
}
variable lambda_runtime {
  description = "Runtime to use for endpoint functions"
  type        = string
  default     = "python3.7"
}
variable lambda_memory_size {
  description = "Memory to allocate to endpoint functions in MB"
  type        = number
}
variable lambda_timeout {
  description = "Timeout in seconds for each function invocation"
  type        = number
  default     = 300
}
variable lambda_layer_arns {
  description = "List of layer ARNs that should be applied to each function"
  type        = list(string)
}
variable environment_variables {
  description = "Map of environment variables to use for each function"
  type        = map(string)
}
variable provisioned_concurrent_executions {
  description = "Number of concurrent execution environments to keep warm for each endpoint function"
  type        = number
  default     = 0
}
variable authorizer_invocation_role {
  description = "Role used by the API Gateway to invoke the authorizer"
  type = object({
    arn = string
  })
}
variable authorizer_role {
  description = "Role assumed by the authorizer"
  type = object({
    arn = string
  })
}
variable rest_api_endpoint_role {
  description = "Role assumed by API endpoint functions"
  type = object({
    arn = string
  })
}
variable api_gateway_logs_role {
  description = "Role assumed by API Gateway to allow logging to CloudWatch"
  type = object({
    arn = string
  })
}
