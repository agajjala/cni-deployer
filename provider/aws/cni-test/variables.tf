variable region {
  description = "Name of the AWS region to deploy to"
}
variable env_name {
  description = "Name of the environment to deploy to"
}
variable deployment_id {
  description = "ID used to further distinguish this deployment"
}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable admin_role_name {
  description = "Name of IAM role with AWS admin privileges on created resources"
  default     = "PCSKAdministratorAccessRole"
}
variable flow_logs_retention_in_days {
  description = "Retention period in days for VPC flow logs"
  type        = number
  default     = 30
}
variable lambda_layers {
  description = "List of lambda layer ARNs to apply on each lambda function"
  type        = list(string)
}
variable artifact_bucket {
  description = "Name of the S3 bucket in which artifacts are stored"
}
variable lambda_layer_s3_key {
  description = "Name of the lambda layer object in the artifact bucket"
}
variable lambda_layer_s3_object_version {
  description = "Version of the lambda layer object in the artifact bucket. A value of $LATEST provides the latest version."
}
variable lambda_function_s3_key {
  description = "Name of the lambda function object in the artifact bucket"
}
variable lambda_function_s3_object_version {
  description = "Version of the lambda layer object in the artifact bucket. A value of $LATEST provides the latest version."
  default     = null
}
variable lambda_memory_size {
  description = "Memory to allocate for each lambda function in MB"
  type        = number
}
variable sfdc_vpn_cidrs {
  description = "List of SFDC VPN CIDRs for access whitelisting"
  type        = list(string)
}
variable inbound_vpc_cidr {
  description = "CIDR of the inbound VPC"
}
variable outbound_vpc_cidr {
  description = "CIDR of the outbound VPC"
}
variable az_count {
  description = "Number of availability zones to deploy to"
  type    = number
  default = 3
}
variable enable_inbound_nat_gateway {
  description = "If true, enables creation of a NAT gateway for each public subnet in the inbound VPC"
  type    = bool
}
variable enable_outbound_nat_gateway {
  description = "If true, enables creation of a NAT gateway for each public subnet in the outbound VPC"
  type    = bool
}
variable write_local_pem_files {
  description = "If true, writes generated private keys as local pem files in the directory of the root module"
  type        = bool
}
variable scaling_config {
  type = object({
    desired_size = number,
    max_size     = number,
    min_size     = number
  })
}
