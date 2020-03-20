output vpc_id {
  value = module.vpc.vpc_id
}

output private_subnet_ids {
  value = module.vpc.private_subnet_ids
}

output public_subnet_ids {
  value = module.vpc.public_subnet_ids
}

output monitoring_ec2_sg_id {
  value = module.security_groups.monitoring_ec2_sg_id
}

output hosted_zone_id {
  value = module.route53_zone.zone_id
}
