variable "deployment_id" {}
variable "tags" {
  type = "map"
}
variable "vpc_type" {
  description = "A prefix to indicate the type of VPC this module will be run against."
}
variable "vpc_id" {}
variable "flow_logs_iam_role_arn" {}
variable "flow_logs_cloudwatch_group_arn" {}
variable "flow_logs_retention_in_days" {}
