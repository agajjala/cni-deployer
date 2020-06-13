variable region {
  type = string
}
variable env_name {
  type = string
}
variable deployment_id {
  type = string
}
variable tags {
  type = map(string)
}
variable admin_role_names {
  type = list(string)
  default = [
    "PCSKAdministratorAccessRole"
  ]
}
variable private_connect_role_name {
  description = "Name to use for the customer-facing Private Connect IAM role"
  type        = string
  default     = ""
}
variable api_authorizer_c2c_key_secret_name {
  description = "Name of the secret containing the C2C key used by the API Gateway authorizer"
  type        = string
}
variable monitoring_s3_bucket {
  description = "ARN of the bucket which stores the input json files for cni-monitoring."
  type = object({
    arn = string
  })
  default = {
    arn = "*"
  }
}
variable write_local_pem_files {
  description = "If true, writes generated private keys as local pem files in the directory of the root module"
  type        = bool
  default     = false
}
variable enable_transit_gateway {
  description = "If false, skips creating the transit gateway."
  type        = bool
  default     = true
}
variable enable_sitebridge {
  description = "If false, skips creating resources related to Sitebridge."
  type        = bool
  default     = true
}
variable sitebridge_config {
  description = <<EOT
    gateway_ips - List of Sitebridge Openswan VPN connection IPs
  EOT
  type = object({
    bgp_asn     = string
    gateway_ips = list(string)
  })
  default = {
    bgp_asn     = ""
    gateway_ips = []
  }
}
