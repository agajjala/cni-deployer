resource aws_security_group sitebridge {
  name   = "${var.resource_prefix}-${var.vpc_type}-sitebridge"
  vpc_id = var.vpc_id

  tags   = var.tags
}
