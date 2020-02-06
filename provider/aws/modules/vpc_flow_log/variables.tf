variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_type {
  description = "A prefix to indicate the type of VPC this module will be run against."
}
variable vpc_id {}
variable flow_logs_iam_role_arn {}
variable admin_role_arn {}
variable retention_in_days {
  type = number
}
