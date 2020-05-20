variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_id {}
variable flow_logs_iam_role_arn {}
variable admin_principals {
  type = list(string)
}
variable retention_in_days {
  type = number
}
