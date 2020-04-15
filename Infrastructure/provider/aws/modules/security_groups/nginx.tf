resource aws_security_group nginx {
  tags   = merge(var.tags, { Name : "${var.resource_prefix}-nginx" })
  name   = "${var.resource_prefix}-nginx"
  vpc_id = var.vpc_id
}

###############################
#  Ingress
###############################

resource aws_security_group_rule nginx_in_allow_private_internet_dynamic_port_range {
  type              = "ingress"
  from_port         = var.endpoint_ingress_port_from
  to_port           = var.endpoint_ingress_port_to
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  security_group_id = aws_security_group.nginx.id
}

###############################
#  Egress
###############################
