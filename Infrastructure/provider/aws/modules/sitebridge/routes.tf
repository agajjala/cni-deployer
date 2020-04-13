resource aws_route data_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.data_plane_cidrs[count.index]
  transit_gateway_id     = var.transit_gateway_id

  count                  = length(var.private_route_table_ids)
}

resource aws_route control_plane {
  route_table_id         = var.private_route_table_ids[count.index]
  destination_cidr_block = var.control_plane_ips[count.index]
  transit_gateway_id     = var.transit_gateway_id

  count                  = length(var.private_route_table_ids)
}
