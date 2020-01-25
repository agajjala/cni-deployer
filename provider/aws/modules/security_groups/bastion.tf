resource "aws_security_group" "bastion" {
  name        = "${var.vpc_type}-bastion-${var.resource_prefix}"
  vpc_id      = var.vpc_id

  tags        = var.tags
}

###############################
#  Ingress (starts)
###############################

resource "aws_security_group_rule" "bastion_sfdc_ssh" {
  type        = "ingress"
  from_port   = "22"
  to_port     = "22"
  protocol    = "tcp"
  cidr_blocks = var.sfdc_cidr_blocks
  security_group_id = aws_security_group.bastion.id
}

###############################
#  Ingress (ends)
###############################

###############################
#  Egress (starts)
###############################

resource "aws_security_group_rule" "bastion_nginx_all" {
  type                     = "egress"
  from_port                = 0
  to_port                  = 0
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.nginx.id
  security_group_id        = aws_security_group.bastion.id
}

###############################
#  Egress (ends)
###############################
