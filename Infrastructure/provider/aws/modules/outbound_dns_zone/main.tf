resource aws_vpc zone_vpc {
  tags                  = merge(var.tags, {Name: "${var.resource_prefix}-zone-vpc"})
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
}

resource aws_route53_zone shared_zone {
  tags = var.tags
  name = var.zone_name
  comment = "${var.resource_prefix}-shared-zone"

  lifecycle {
    ignore_changes = [vpc]
  }

  vpc {
    vpc_id = aws_vpc.zone_vpc.id
  }
}