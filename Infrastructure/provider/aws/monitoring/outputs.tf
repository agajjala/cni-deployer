output vpc_id {
  value = module.vpc.vpc_id
}

output private_subnets {
  value = module.vpc.private_subnets
}

output public_subnets {
  value = module.vpc.public_subnets
}

output zone {
  value = aws_route53_zone.zone
}

output security_groups {
  value = module.security_groups
}
