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
variable force_destroy_artifact_bucket {
  description = "If true, deletion of the bucket will result in deletion of all bucket objects"
  type        = bool
  default     = false
}
variable force_destroy_access_log_bucket {
  description = "If true, deletion of the bucket will result in deletion of all bucket objects"
  type        = bool
  default     = false
}
variable sitebridge_config {
  description = <<EOT
    gateway_ips - List of Sitebridge Openswan VPN connection IPs
  EOT
  type = object({
    bgp_asn           = string
    gateway_ips       = list(string)
  })
}
