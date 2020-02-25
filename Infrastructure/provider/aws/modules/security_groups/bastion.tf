resource "aws_security_group" "bastion" {
  name        = "${var.resource_prefix}-bastion"
  vpc_id      = var.vpc_id

  tags        = var.tags
}

###############################
#  Ingress
###############################

resource aws_security_group_rule bastion_in_allow_sfdc_ssh {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "tcp"
  cidr_blocks       = var.sfdc_cidr_blocks
  security_group_id = aws_security_group.bastion.id
}

###############################
#  Egress
###############################

resource aws_security_group_rule bastion_out_allow_all_nginx_tcp {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx.id
  security_group_id        = aws_security_group.bastion.id
}
