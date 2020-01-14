variable deployment_id {}
variable tags {
  type = "map"
}
variable vpc_id {}
variable vpc_type {}
variable security_group_ids {
  type = list(string)
}
variable private_subnet_ids {
  type = list(string)
}
variable sitebridge_control_plane_ips {
  type = list(string)
}
variable forwarded_domains {
  type = list(string)
}
