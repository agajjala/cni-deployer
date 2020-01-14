resource aws_customer_gateway default {
  bgp_asn    = var.bgp_asn
  ip_address = var.gateway_ips[count.index]
  type       = "ipsec.1"

  count      = length(var.gateway_ips)
}

resource aws_vpn_connection default {
  customer_gateway_id = aws_customer_gateway.default[count.index].id
  transit_gateway_id  = var.transit_gateway_id
  type                = aws_customer_gateway.default[count.index].type

  count               = length(var.gateway_ips)
}
