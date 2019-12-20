resource "aws_route53_zone" "zone" {
  name = "${var.zone_name}"

  vpc {
    vpc_id = "${var.vpc_id}"
  }

  tags = "${var.tags}"
}
