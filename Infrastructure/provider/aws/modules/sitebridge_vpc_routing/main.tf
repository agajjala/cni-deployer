###############################
#  Routes
###############################

resource aws_route data_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.data_plane_cidrs[count.index]
  transit_gateway_id     = var.transit_gateway[0].id

  count                  = var.enable_sitebridge ? length(var.private_route_table_ids) : 0
}

resource aws_route control_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.control_plane_ips[count.index]
  transit_gateway_id     = var.transit_gateway[0].id

  count                  = var.enable_sitebridge ? length(var.private_route_table_ids) : 0
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

  count             = var.enable_sitebridge ? 1 : 0
}

resource aws_security_group_rule sitebridge_inbound_data_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = toset(var.data_plane_cidrs)
  security_group_id = var.sitebridge_sg_id

  count             = var.enable_sitebridge ? 1 : 0
}

###############################
#  Route53 Resolvers
###############################

resource aws_route53_resolver_endpoint outbound {
  tags               = var.tags
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

  count              = var.enable_sitebridge ? 1 : 0
}

resource aws_route53_resolver_rule rules {
  name                 = "${var.resource_prefix}-${count.index}"
  domain_name          = var.forwarded_domains[count.index]
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound[0].id

  dynamic target_ip {
    for_each = var.control_plane_ips
    iterator = control_ip
    content {
      ip   = trimsuffix(control_ip.value, "/32")
      port = 53
    }
  }

  count                = var.enable_sitebridge ? length(var.forwarded_domains) : 0
}

resource aws_route53_resolver_rule_association associations {
  name             = "${var.resource_prefix}-${count.index}"
  resolver_rule_id = aws_route53_resolver_rule.rules[count.index].id
  vpc_id           = var.vpc_id

  count = var.enable_sitebridge ? length(var.forwarded_domains) : 0
}
