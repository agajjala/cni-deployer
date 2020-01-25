variable region {}
variable env_name {}
variable deployment_id {}
variable tags {
  type = map(string)
}
variable admin_role_name {
  default = "PCSKAdministratorAccessRole"
}
variable flow_logs_retention_in_days {
  type    = number
  default = 30
}
variable sfdc_vpn_cidrs {
  type = list(string)
}
variable inbound_vpc_cidr {}
variable outbound_vpc_cidr {}
variable az_count {
  type    = number
  default = 3
}
