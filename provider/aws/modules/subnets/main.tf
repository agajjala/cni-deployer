resource "aws_subnet" "public" {
  vpc_id                = var.vpc_id
  cidr_block            = cidrsubnet(var.vpc_cidr, 3, 0 + count.index)
  availability_zone_id  = element(var.subnet_az_ids, count.index)

  tags                  = var.tags

  count                 = length(var.subnet_az_ids)
}

resource "aws_subnet" "private" {
  vpc_id                = var.vpc_id
  cidr_block            = cidrsubnet(var.vpc_cidr, 3, length(var.subnet_az_ids) + count.index)
  availability_zone_id  = element(var.subnet_az_ids, count.index)

  tags                  = var.tags

  count                 = length(var.subnet_az_ids)
}
