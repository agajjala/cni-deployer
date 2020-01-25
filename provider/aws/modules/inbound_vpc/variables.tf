variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_cidr {}
variable sfdc_cidr_blocks {
  type = list(string)
}
variable az_count {
  type = number
}
variable zone_name {}
variable flow_logs_iam_role_arn {}
variable flow_logs_cloudwatch_group_arn {}
//variable transit_gateway_id {}
//variable sitebridge_bgp_asn {}
//variable sitebridge_gateway_ips {
//  type = list(string)
//}
//variable sitebridge_data_plane_ips {
//  type = list(string)
//}
//variable sitebridge_control_plane_ips {
//  type = list(string)
//}
//variable forwarded_domains {
//  type = list(string)
//}
