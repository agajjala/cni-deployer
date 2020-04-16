###############################
#  Routes
###############################

resource aws_route data_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.data_plane_cidrs[count.index]
  transit_gateway_id     = var.transit_gateway.id

  count                  = length(var.private_route_table_ids)
}

resource aws_route control_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.control_plane_ips[count.index]
  transit_gateway_id     = var.transit_gateway.id

  count                  = length(var.private_route_table_ids)
}

###############################
#  Ingress Rules
###############################

resource aws_security_group_rule sitebridge_inbound_mtu_discovery {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.sitebridge_sg_id
}

resource aws_security_group_rule sitebridge_inbound_data_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = toset(var.data_plane_cidrs)
  security_group_id = var.sitebridge_sg_id
}

###############################
#  Route53 Resolvers
###############################

resource aws_route53_resolver_endpoint outbound {
  name               = var.resource_prefix
  direction          = "OUTBOUND"
  security_group_ids = [var.sitebridge_sg_id]

  dynamic ip_address {
    for_each = var.private_subnet_ids
    iterator = subnet_id
    content {
      subnet_id = subnet_id.value
    }
  }

  tags = var.tags
}

resource aws_route53_resolver_rule rules {
  name                 = "${var.resource_prefix}-${count.index}"
  domain_name          = var.forwarded_domains[count.index]
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic target_ip {
    for_each = var.control_plane_ips
    iterator = control_ip
    content {
      ip   = trimsuffix(control_ip.value, "/32")
      port = 53
    }
  }

  count = length(var.forwarded_domains)
}

resource aws_route53_resolver_rule_association associations {
  name             = "${var.resource_prefix}-${count.index}"
  resolver_rule_id = aws_route53_resolver_rule.rules[count.index].id
  vpc_id           = var.vpc_id

  count = length(var.forwarded_domains)
}
