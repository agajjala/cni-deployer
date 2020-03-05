resource "aws_security_group" "nginx" {
  name        = "${var.resource_prefix}-nginx"
  vpc_id      = var.vpc_id

  tags        = var.tags
}

###############################
#  Ingress
###############################

resource aws_security_group_rule nginx_in_allow_bastion_ssh {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  source_security_group_id  = aws_security_group.bastion.id
  security_group_id         = aws_security_group.nginx.id
}

resource aws_security_group_rule nginx_in_allow_private_internet_443 {
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
