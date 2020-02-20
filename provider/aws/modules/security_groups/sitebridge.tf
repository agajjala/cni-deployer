resource aws_security_group sitebridge {
  name   = "${var.resource_prefix}-sitebridge"
  vpc_id = var.vpc_id

  tags   = var.tags
}
