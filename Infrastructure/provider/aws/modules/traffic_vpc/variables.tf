variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_cidr {}
variable sfdc_cidr_blocks {
  type = list(string)
}
variable az_names {
  type = list(string)
}
variable enable_nat_gateway {
  type    = bool
  default = false
}
variable zone_name {}
variable admin_role_arn {}
variable flow_log_retention_in_days {}
variable flow_log_iam_role_arn {}
variable data_plane_cluster_name {}
variable data_plane_cluster_role_arn {}
variable data_plane_cluster_role_name {}
variable data_plane_node_role_arn {}
variable data_plane_node_role_name {}
variable transit_gateway_id {}
variable bastion_autoscaling_group_role_arn {}
variable bastion_image_id {}
variable bastion_instance_profile_arn {}
variable bastion_key_name {}
variable node_group_key_name {}
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
