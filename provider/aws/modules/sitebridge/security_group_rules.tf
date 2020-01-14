###############################
#  Ingress (starts)
###############################

resource aws_security_group_rule sitebridge_inbound_mtu_discovery {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.sitebridge_security_group_id
}

resource aws_secuirty_group_rule sitebridge_inbound_data_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = formatlist(local.data_plane_cdir_template, var.data_plane_ips)
  security_group_id = var.sitebridge_security_group_id
}

resource aws_secuirty_group_rule sitebridge_inbound_control_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = formatlist(local.control_plane_cidr_template, var.control_plane_ips)
  security_group_id = var.sitebridge_security_group_id
}

###############################
#  Ingress (ends)
###############################

###############################
#  Egress (starts)
###############################

resource aws_secuirty_group_rule sitebridge_outbound_data_plane_all_ports {
  type              = "outbound"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = formatlist(local.data_plane_cdir_template, var.data_plane_ips)
  security_group_id = var.sitebridge_security_group_id
}

resource aws_secuirty_group_rule sitebridge_outbound_control_plane_all_ports {
  type              = "outbound"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = formatlist(local.control_plane_cidr_template, var.control_plane_ips)
  security_group_id = var.sitebridge_security_group_id
}

###############################
#  Egress (ends)
###############################
