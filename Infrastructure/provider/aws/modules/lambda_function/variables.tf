variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable function_name {
  description = "Name of the function"
}
variable role_arn {
  description = "ARN of the IAM role this function should assume"
}
variable s3_bucket {
  description = "Name of the s3 bucket in which lambda artifacts are stored"
}
variable s3_key {
  description = "Name of the function artifact"
}
variable s3_object_version {
  description = "Version of the object in the S3 bucket used to create the lambda function. Omitting this field defaults to the latest version."
  default     = ""
}
variable runtime {
  description = "Name of the runtime to use"
  default     = "python3.7"
}
variable handler {
  description = "Name of the function handler"
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
  description = "Timeout in seconds for each lambda invocation"
  type        = number
  default     = 300
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
variable environment_variables {
  description = "Map of environment variables to set in the function's execution environment"
  type        = map(string)
  default     = {}
}
