variable table_name {}
variable table_hash_key {}
variable api_key {}
variable vpce_connections_topic_arn {}
variable private_link_access_role_arn {}
variable vpc_id {}
variable private_subnet_ids {
  type = list(string)
}
variable nlb_protocol {
  type    = string
  default = "https"
}
variable nlb_port {
  type    = number
  default = 443
}
variable nlb_dns_name {}
variable nginx_sg_id {}
variable hosted_zone_id {}
variable hosted_zone_name {}