variable region {}
variable access_key {}
variable secret_key {}

variable deployment_id {}

variable tags {
  type = "map"
}
variable vpc_cidr_block {}
variable sfdc_cidr {}
variable public_subnet_count {}
variable public_subnet_cidr_blocks {
  type = list(string)
}
variable public_subnet_availability_zone_ids {
  type = list(string)
}

variable private_subnet_count {}
variable private_subnet_cidr_blocks {
  type = list(string)
}
variable private_subnet_availability_zone_ids {
  type = list(string)
}
variable inbound_zone_name {}
variable zone_name {}
variable flow_logs_retention_in_days {}
variable transit_gateway_id {}
variable sitebridge_bgp_asn {}
variable sitebridge_gateway_ips {
  type = list(string)
}
variable sitebridge_data_plane_ips {
  type = list(string)
}
variable sitebridge_control_plane_ips {
  type = list(string)
}
variable forwarded_domains {
  type = list(string)
}
