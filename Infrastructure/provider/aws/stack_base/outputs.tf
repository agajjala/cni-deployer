output iam {
  value = module.iam
}

output transit_gateway {
  value = aws_ec2_transit_gateway.default
}

output customer_gateways {
  value = aws_customer_gateway.default.*
}

output vpn_connections {
  value = aws_vpn_connection.default.*
}

output outbound_dns_zone {
  value = aws_route53_zone.outbound_dns_zone
}

output sitebridge_dns_zone {
  value = aws_route53_zone.sitebridge_dns_zone
}

output outbound_bastion_key_pair {
  value = module.outbound_bastion_key_pair.key
}

output outbound_node_group_key_pair {
  value = module.outbound_node_group_key_pair.key
}
