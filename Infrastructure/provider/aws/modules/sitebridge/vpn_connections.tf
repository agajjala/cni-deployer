resource aws_customer_gateway default {
  bgp_asn    = var.bgp_asn
  ip_address = local.gateway_ips_without_suffix[count.index]
  type       = "ipsec.1"

  count      = length(var.gateway_ips)
}

resource aws_vpn_connection default {
  tags                = merge(var.tags, {Name: "${var.resource_prefix}-${count.index}"})
  customer_gateway_id = aws_customer_gateway.default[count.index].id
  transit_gateway_id  = var.transit_gateway_id
  type                = aws_customer_gateway.default[count.index].type

  count               = length(var.gateway_ips)
}
