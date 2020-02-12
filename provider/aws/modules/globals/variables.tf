variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable admin_role_arn {}
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
variable artifact_bucket {}
variable lambda_layer_s3_key {}
variable lambda_layer_s3_object_version {}
variable lambda_function_s3_key {}
variable lambda_function_s3_object_version {}
variable lambda_memory_size {}
variable lambda_layers {
  type = list(string)
}
