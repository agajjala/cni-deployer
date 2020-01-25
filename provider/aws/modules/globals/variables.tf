variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable admin_role_name {}
variable flow_logs_retention_in_days {}
variable inbound_nginx_ecr_repo_arn {
  default = "*"
}
variable inbound_nginx_s3_bucket_arn {
  default = "*"
}
variable outbound_nginx_ecr_repo_arn {
  default = "*"
}
variable outbound_nginx_s3_bucket_arn {
  default = "*"
}
