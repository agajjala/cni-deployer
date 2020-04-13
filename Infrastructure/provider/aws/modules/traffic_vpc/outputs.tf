output vpc_id {
  value = module.vpc.vpc_id
}

output vpc {
  value = module.vpc.vpc
}

output private_subnet_ids {
  value = module.vpc.private_subnet_ids
}

output private_subnets {
  value = module.vpc.private_subnets
}

output public_subnet_ids {
  value = module.vpc.public_subnet_ids
}

output public_subnets {
  value = module.vpc.public_subnets
}

output private_route_table_ids {
  value = module.vpc.private_route_table_ids
}

output nginx_sg_id {
  value = module.security_groups.nginx_sg_id
}

output sitebridge_sg_id {
  value = module.security_groups.sitebridge_sg_id
}

output hosted_zone_id {
  value = module.route53_zone.zone_id
}

output zone {
  value = module.route53_zone.zone
}

output cluster {
  value = module.eks_cluster.cluster
}

output node_group {
  value = module.eks_cluster.node_group
}

output security_groups {
  value = module.security_groups
}