resource "aws_vpc_endpoint_service" "service" {
  acceptance_required        = true
  network_load_balancer_arns = ["${module.load_balancers.private_network_lb_arn}"]

  tags                       = "${var.tags}"
}

resource "aws_vpc_endpoint_service_allowed_principal" "all_principals" {
  vpc_endpoint_service_id = "${aws_vpc_endpoint_service.service.id}"
  principal_arn           = "*"
}
