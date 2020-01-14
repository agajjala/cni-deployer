resource aws_route data_plane {
  route_table_id         = var.route_table_id
  destination_cidr_block = format(local.data_plane_cdir_template, var.data_plane_ips[count.index])
  transit_gateway_id     = var.transit_gateway_id

  count                  = length(var.data_plane_ips)
}

resource aws_route control_plane {
  route_table_id         = var.route_table_id
  destination_cidr_block = format(local.control_plane_cidr_template, var.control_plane_ips[count.index])
  transit_gateway_id     = var.transit_gateway_id

  count                  = length(var.control_plane_ips)
}
