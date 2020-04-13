variable tags {
  type = map(string)
}
variable log_group_name {}
variable retention_in_days {}
variable admin_role_arns {
  type = list(string)
}
variable kms_key_source_json {}
