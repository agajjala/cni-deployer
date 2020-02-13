variable region {
  description = "Name of the AWS region to deploy to"
  type        = string
}
variable env_name {
  description = "Name of the environment to deploy to"
  type        = string
  default     = "test"
}
variable deployment_id {
  description = "Short ID used to further distinguish a deployment. Must be less than 10 characters."
  type        = string
}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable admin_role_name {
  description = "Name of IAM role with AWS admin privileges on created resources"
  type        = string
  default     = "PCSKAdministratorAccessRole"
}
variable flow_logs_retention_in_days {
  description = "Retention period in days for VPC flow logs"
  type        = number
  default     = 30
}
variable artifact_bucket {
  description = "Name of the S3 bucket in which artifacts are stored"
  type        = string
}
variable lambda_layer_s3_key {
  description = "Name of the lambda layer object in the artifact bucket"
  type        = string
}
variable lambda_layer_s3_object_version {
  description = "Version of the object in the artifact bucket used to create the lambda layer. Omitting this field defaults to the latest version."
  type        = string
  default     = ""
}
variable lambda_function_s3_key {
  description = "Name of the lambda function object in the artifact bucket"
  type        = string
}
variable lambda_function_s3_object_version {
  description = "Version of the object in the artifact bucket used to create the lambda function. Omitting this field defaults to the latest version."
  type        = string
  default     = ""
}
variable lambda_memory_size {
  description = "Memory to allocate for each lambda function in MB"
  type        = number
  default     = 256
}
variable sfdc_vpn_cidrs {
  description = "List of SFDC VPN CIDRs for access whitelisting"
  type        = list(string)
  default     = ["204.14.239.0/24"]
}
variable inbound_vpc_cidr {
  description = "CIDR of the inbound VPC"
  type        = string
}
variable inbound_data_plane_cluster_name {
  description = "Name to give the inbound data plane cluster in EKS"
  type        = string
}
variable outbound_vpc_cidr {
  description = "CIDR of the outbound VPC"
  type        = string
}
variable outbound_data_plane_cluster_name {
  description = "Name to give the outbound data plane cluster in EKS"
  type        = string
}
variable az_count {
  description = "Number of availability zones to deploy to"
  type        = number
  default     = 3
}
variable enable_inbound_nat_gateway {
  description = "If true, enables creation of a NAT gateway for each public subnet in the inbound VPC"
  type        = bool
  default     = true
}
variable enable_outbound_nat_gateway {
  description = "If true, enables creation of a NAT gateway for each public subnet in the outbound VPC"
  type        = bool
  default     = true
}
variable write_local_pem_files {
  description = "If true, writes generated private keys as local pem files in the directory of the root module"
  type        = bool
  default     = true
}
