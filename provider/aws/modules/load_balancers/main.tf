resource "aws_lb" "private_network" {
  name                             = "${var.vpc_type}-private-network-${var.deployment_id}"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = var.private_subnet_ids
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true

  tags                             = var.tags
}

resource "aws_lb_target_group" "traffic_proxy" {
  name     = "${var.vpc_type}-traffic-proxy-${var.deployment_id}"
  port     = 8443
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  tags     = var.tags
}

resource "aws_lb_listener" "traffic_proxy" {
  load_balancer_arn = aws_lb.private_network.arn
  port              = "443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.traffic_proxy.arn
  }
}
