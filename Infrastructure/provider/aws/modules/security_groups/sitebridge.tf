resource aws_security_group sitebridge {
  tags   = merge(var.tags, { Name : "${var.resource_prefix}-sitebridge" })
  name   = "${var.resource_prefix}-sitebridge"
  vpc_id = var.vpc_id
}
