variable tags {
  type = map(string)
}
variable resource_prefix {}
variable vpc_id {}
variable private_subnet_ids {
  type = list(string)
}
variable private_route_table_ids {
  type = list(string)
}
variable data_plane_cidrs {
  description = "List of Sitebridge NAT pool CIDRs"
  type        = list(string)
}
variable control_plane_ips {
  description = "List of Sitebridge control plane IPs"
  type        = list(string)
}
variable transit_gateway {
  type = object({
    id = string
  })
}
variable sitebridge_sg_id {
  type = string
}
variable forwarded_domains {
  type = list(string)
}
