resource aws_security_group sitebridge {
  name   = "${var.vpc_type}-sitebridge-${var.deployment_id}"
  vpc_id = var.vpc_id

  tags   = var.tags
}
