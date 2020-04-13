resource aws_route53_resolver_endpoint outbound {
  name               = var.resource_prefix
  direction          = "OUTBOUND"
  security_group_ids = [var.sitebridge_security_group_id]

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
