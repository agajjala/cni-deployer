resource aws_security_group data_plane_cluster {
  name        = "${var.resource_prefix}-dp-cluster"
  vpc_id      = var.vpc_id

  tags        = var.tags
}

###############################
#  Ingress
###############################

resource aws_security_group_rule data_plane_cluster_in_allow_self_all {
  type                     = "ingress"
  from_port                = "0"
  to_port                  = "0"
  protocol                 = "-1"
  source_security_group_id = aws_security_group.data_plane_cluster.id
  security_group_id        = aws_security_group.data_plane_cluster.id
}

###############################
#  Egress
###############################

resource aws_security_group_rule data_plane_cluster_out_allow_all {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.data_plane_cluster.id
}
