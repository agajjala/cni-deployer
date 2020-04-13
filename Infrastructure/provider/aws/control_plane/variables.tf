variable env_name {}
variable region {}
variable deployment_id {}
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
variable lambda_layer_s3_key {
  description = "Name of the lambda layer object in the S3 bucket"
  type        = string
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
variable lambda_provisioned_concurrent_executions {
  description = "Number of concurrent execution environments to keep warm for each endpoint function"
  type        = number
  default     = 0
}
variable vpc_suffix {
  description = "Suffix of the outbound VPC"
  type        = string
}
