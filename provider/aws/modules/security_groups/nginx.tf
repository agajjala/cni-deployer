resource "aws_security_group" "nginx" {
  name        = "${var.vpc_type}-nginx-${var.deployment_id}"
  vpc_id      = var.vpc_id

  tags        = var.tags
}

###############################
#  Ingress (starts)
###############################

resource "aws_security_group_rule" "nginx_bastion_ssh" {
  type        = "ingress"
  from_port   = "22"
  to_port     = "22"
  protocol    = "tcp"
  source_security_group_id  = aws_security_group.bastion.id
  security_group_id         = aws_security_group.nginx.id
}

resource "aws_security_group_rule" "nginx_private_internet_443" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  security_group_id = aws_security_group.nginx.id
}

###############################
#  Ingress (ends)
###############################

###############################
#  Egress (starts)
###############################

###############################
#  Egress (ends)
###############################
