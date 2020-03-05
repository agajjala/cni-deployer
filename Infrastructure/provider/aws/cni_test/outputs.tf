output private_link_access_role_arn {
  value = module.globals.private_link_access_role_arn
}

output inbound_vpc_id {
  value = module.inbound_vpc.vpc_id
}

output inbound_private_subnet_ids {
  value = module.inbound_vpc.private_subnet_ids
}

output inbound_public_subnet_ids {
  value = module.inbound_vpc.public_subnet_ids
}

output inbound_nginx_sg_id {
  value = module.inbound_vpc.nginx_sg_id
}

output inbound_hosted_zone_id {
  value = module.inbound_vpc.hosted_zone_id
}

output inbound_hosted_zone_name {
  value = local.inbound_hosted_zone_name
}

output inbound_data_plane_cluster_name {
  value = local.inbound_data_plane_cluster_name
}

output inbound_config_table_name {
  value = module.globals.inbound_config_table_name
}

output inbound_config_hash_key {
  value = module.globals.inbound_config_hash_key
}

output inbound_vpce_connections_topic_arn {
  value = module.globals.inbound_vpce_connections_topic_arn
}

output outbound_vpc_id {
  value = module.outbound_vpc.vpc_id
}

output outbound_private_subnet_ids {
  value = module.outbound_vpc.private_subnet_ids
}

output outbound_public_subnet_ids {
  value = module.outbound_vpc.public_subnet_ids
}

output outbound_nginx_sg_id {
  value = module.outbound_vpc.nginx_sg_id
}

output outbound_hosted_zone_id {
  value = module.outbound_vpc.hosted_zone_id
}

output outbound_hosted_zone_name {
  value = local.outbound_hosted_zone_name
}

output outbound_data_plane_cluster_name {
  value = local.outbound_data_plane_cluster_name
}

output outbound_config_table_name {
  value = module.globals.outbound_config_table_name
}

output outbound_config_hash_key {
  value = module.globals.outbound_config_hash_key
}

output outbound_vpce_connections_topic_arn {
  value = module.globals.outbound_vpce_connections_topic_arn
}
