output vpc {
  value = module.vpc.vpc
}

output private_subnets {
  value = module.vpc.private_subnets
}

output public_subnets {
  value = module.vpc.public_subnets
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
