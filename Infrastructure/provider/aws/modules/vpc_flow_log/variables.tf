variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_id {}
variable flow_logs_iam_role_arn {}
variable admin_role_arns {
  type = list(string)
}
variable retention_in_days {
  type = number
}
