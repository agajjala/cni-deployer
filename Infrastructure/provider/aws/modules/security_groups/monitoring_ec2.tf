resource aws_security_group monitoring_ec2 {
  name              = "${var.resource_prefix}-monitoring-ec2"
  vpc_id            = var.vpc_id
  tags              = var.tags
}

resource aws_security_group_rule monitoring_ec2_in_allow_sfdc_ssh {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.sfdc_cidr_blocks
  security_group_id = aws_security_group.monitoring_ec2.id
}

resource aws_security_group_rule monitoring_ec2_in_allow_sfdc_and_kaiju_http {
  type              = "ingress"
  from_port         = 80   # TODO: Eanble 443
  to_port           = 80   # TODO: Enable 443
  protocol          = "tcp"
  cidr_blocks       = var.sfdc_cidr_blocks # TODO: Modify it to include Kaiju Agent IPs
  security_group_id = aws_security_group.monitoring_ec2.id
}

resource aws_security_group_rule monitoring_ec2_out_allow_all {
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.monitoring_ec2.id
}
