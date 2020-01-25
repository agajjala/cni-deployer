variable deployment_id {}
variable tags {
  type = map(string)
}
variable vpc_id {}
variable private_subnet_ids {
  type = list(string)
}
variable route_table_id {}
variable bgp_asn {}
variable gateway_ips {
  type = list(string)
}
variable data_plane_ips {
  type = list(string)
}
variable control_plane_ips {
  type = list(string)
}
variable transit_gateway_id {}
variable sitebridge_security_group_id {}
