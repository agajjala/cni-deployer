variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable function_name {
  description = "Name of the function"
  type = string
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
  type = string
}
variable s3_object_version {
  description = "Version of the object in the S3 bucket used to create the function. Omitting this field defaults to the latest version."
  default     = ""
}
variable runtime {
  description = "Name of the runtime to use"
  default     = "python3.7"
}
variable handler {
  description = "Name of the function handler"
  type = string
}
variable memory_size {
  description = "Memory to allocate to the function in MB"
  type        = number
}
variable enable_tracing {
  description = "If true, enables tracing in the function using AWS X-Ray"
  type        = bool
  default     = true
}
variable layers {
  description = "List of lambda layer ARNs to apply on the function"
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
  type = number
}
variable has_schedule {
  description = "If true, enables invocation of the function based on a schedule expression"
  type        = bool
  default     = false
}
variable schedule {
  description = "Schedule expression used to schedule invocations. Must be provided if has_schedule is true"
  default     = ""
}
variable has_event_source {
  description = "If true, enables invocation of the function based on an event source"
  type        = bool
  default     = false
}
variable event_source_arn {
  description = "ARN of the event source. Must be provided if has_event_source is true"
  default     = ""
}
variable has_sns_topic {
  description = "If true, enables invocation of the function based on subscription to a SNS topic"
  type        = bool
  default     = false
}
variable sns_topic_arn {
  description = "ARN of the SNS topic to subscribe to. Must be provided if has_sns_topic is true"
  default     = ""
}
