###############################
#  Ingress
###############################

resource aws_security_group_rule sitebridge_inbound_mtu_discovery {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "icmp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = var.sitebridge_security_group_id
}

resource aws_security_group_rule sitebridge_inbound_data_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = toset(var.data_plane_cidrs)
  security_group_id = var.sitebridge_security_group_id
}

resource aws_security_group_rule sitebridge_inbound_control_plane_all_ports {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = var.control_plane_ips
  security_group_id = var.sitebridge_security_group_id
}

###############################
#  Egress
###############################

resource aws_security_group_rule sitebridge_outbound_data_plane_all_ports {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = toset(var.data_plane_cidrs)
  security_group_id = var.sitebridge_security_group_id
}

resource aws_security_group_rule sitebridge_outbound_control_plane_all_ports {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = var.control_plane_ips
  security_group_id = var.sitebridge_security_group_id
}
