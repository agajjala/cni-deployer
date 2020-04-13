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
variable resource {
  description = "The API Gateway resource to attach to"
  type = object({
    id   = string
    path = string
  })
}
variable http_method {
  description = "HTTP method to use"
  type        = string
}
variable authorization {
  description = "Type of API Gateway authorization to use"
  type        = string
}
variable authorizer_id {
  description = "ID of an API Gateway Authorizer to use"
  type        = string
}
variable function_name {
  description = "Name of the function"
  type        = string
}
variable function_role {
  description = "Role assumed by the function"
  type = object({
    arn = string
  })
}
variable artifact_bucket {
  description = "Bucket containing code artifacts"
  type = object({
    bucket = string
  })
}
variable s3_key {
  description = "Path to the function artifact in the S3 bucket"
  type        = string
}
variable runtime {
  description = "Runtime to use for endpoint functions"
  type        = string
}
variable handler {
  description = "Name of the function handler"
  type        = string
}
variable memory_size {
  description = "Memory to allocate to endpoint functions in MB"
  type        = number
}
variable layers {
  description = "List of layers to apply to endpoint functions"
  type        = list(string)
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
  description = "Number of concurrent execution environments to keep warm for the function"
  type        = number
}
