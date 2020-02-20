variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_id {}
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
