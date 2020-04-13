output iam {
  value = module.iam
}

output transit_gateway {
  value = aws_ec2_transit_gateway.default
}

output outbound_dns_zone {
  value = module.outbound_dns_zone
}

output outbound_bastion_key_pair {
  value = module.outbound_bastion_key_pair.key
}

output outbound_node_group_key_pair {
  value = module.outbound_node_group_key_pair.key
}
