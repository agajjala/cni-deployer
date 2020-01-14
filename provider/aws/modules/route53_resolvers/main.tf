resource aws_route53_resolver_endpoint outbound {
  name      = "${var.vpc_type}-${var.deployment_id}"
  direction = "OUTBOUND"

  security_group_ids = var.security_group_ids

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
  name                 = "${var.vpc_type}-${var.forwarded_domains[count.index]}-${var.deployment_id}"
  domain_name          = var.forwarded_domains[count.index]
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.outbound.id

  dynamic "target_ip" {
    for_each = var.sitebridge_control_plane_ips
    iterator = control_ip
    content {
      ip   = control_ip.value
      port = 53
    }
  }

  count = length(var.forwarded_domains)
}

resource aws_route53_resolver_rule_association associations {
  name             = "${var.vpc_type}-${var.forwarded_domains[count.index]}-${var.deployment_id}"
  resolver_rule_id = aws_route53_resolver_rule.rules[count.index].id
  vpc_id           = var.vpc_id

  count = length(var.forwarded_domains)
}
