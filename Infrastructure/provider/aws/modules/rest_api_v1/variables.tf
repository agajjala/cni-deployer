variable resource_prefix {}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable rest_api {
  description = "An API Gateway REST API object"
  type = object({
    id               = string
    root_resource_id = string
    execution_arn    = string
  })
}
variable authorization {
  description = "Type of API Gateway authorization to use"
  type = string
}
variable gdot_url {
  description = "URL of the GDOT endpoint to use for the API Gateway authorizer"
  type = string
}
variable c2c_key_secret_name {
  description = "Name of the C2C key secret in Secrets Manager"
  type = string
}
variable stage_name {
  description = "Name of the API Gateway stage"
  type = string
}
variable artifact_bucket {
  description = "Bucket containing code artifacts"
  type = object({
    bucket = string
  })
}
variable s3_key {
  description = "Path to the function artifact in the S3 bucket"
  type = string
}
variable runtime {
  description = "Runtime to use for endpoint functions"
  type = string
}
variable memory_size {
  description = "Memory to allocate to endpoint functions in MB"
  type = number
}
variable layers {
  description = "List of layers to apply to endpoint functions"
  type = list(string)
}
variable timeout {
  description = "Timeout in seconds for each function invocation"
  type        = number
}
variable environment_variables {
  description = "Map of environment variables to set in the function's execution environment"
  type        = map(string)
  default     = {}
}
variable provisioned_concurrent_executions {
  description = "Number of concurrent execution environments to keep warm for each endpoint function"
  type = number
}
variable authorizer_role {
  description = "IAM role to use for the API Gateway authorizer"
  type = object({
    arn = string
  })
}
variable authorizer_invocation_role {
  description = "IAM role to use for invoking the API Gateway authorizer"
  type = object({
    arn = string
  })
}
variable rest_api_endpoint_role {
  description = "IAM role to use for REST API endpoint lambda functions"
  type = object({
    arn = string
  })
}
