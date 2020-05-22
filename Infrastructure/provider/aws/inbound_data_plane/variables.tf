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
variable flow_logs_retention_in_days {
  description = "Retention period in days for VPC flow logs"
  type        = number
  default     = 30
}
variable sfdc_vpn_cidrs {
  description = "List of SFDC VPN CIDRs for access whitelisting"
  type        = list(string)
  default     = [
    # AmerWest
    "204.14.239.17/32",
    "204.14.239.18/32",
    "204.14.239.13/32",
    "204.14.239.105/32",
    "204.14.239.106/32",
    "204.14.239.107/32",
    "204.14.239.82/32",
    # AmerWest1
    "13.110.54.0/26",
    # CodeBuild
    "52.43.76.88/29"]
}
variable inbound_vpc_cidr {
  description = "CIDR of the inbound VPC"
  type        = string
  default     = "10.20.8.0/22"
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
variable enable_inbound_private_nat_routes {
  description = "If true, creates routes in private subnet route tables to route traffic to a NAT gateway. Has no effect is NAT gateways are not enabled."
  type        = bool
  default     = true
}
variable write_local_pem_files {
  description = "If true, writes generated private keys as local pem files in the directory of the root module"
  type        = bool
  default     = true
}
variable inbound_vpc_private_subnet_cidrs {
  description = "List of the CIDRs to use for the inbound VPC private subnets"
  type        = list(string)
  default     = []
}
variable inbound_vpc_public_subnet_cidrs {
  description = "List of the CIDRs to use for the inbound VPC public subnets"
  type        = list(string)
  default     = []
}
variable inbound_data_plane_node_group_instance_types {
  description = "Set of instance types to associate with the inbound data plane node group"
  type        = list(string)
  default     = ["t3.medium"]
}
variable inbound_data_plane_node_group_desired_size {
  description = "The number of hosts desired for the inbound data plane node group"
  type        = number
  default     = 3
}
variable inbound_data_plane_node_group_max_size {
  description = "The maximum number of hosts to create in the inbound data plane node group"
  type        = number
  default     = 3
}
variable inbound_data_plane_node_group_min_size {
  description = "The minimum number of hosts to create in the inbound data plane node group"
  type        = number
  default     = 3
}
variable enable_sitebridge {
  description = "If false, skips creating resources related to Sitebridge."
  type        = bool
  default     = true
}
variable sitebridge_config {
  description = <<EOT
    control_plane_ips - List of Sitebridge control plane IPs
    data_plane_cidrs  - List of Sitebridge NAT pool CIDRs
    forwarded_domains - List of domains to route using a Sitebridge VPN connection
  EOT
  type = object({
    control_plane_ips = list(string)
    data_plane_cidrs  = list(string)
    forwarded_domains = list(string)
  })
  default = {
    control_plane_ips = []
    data_plane_cidrs  = []
    forwarded_domains = []
  }
}
