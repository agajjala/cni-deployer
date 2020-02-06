locals {
  vpc_tags                   = merge(var.tags, var.additional_vpc_tags)
  subnet_tags                = merge(var.tags, var.additional_subnet_tags)
  /*
    A VPC requires fewer public addresses to be allocated compared to private addresses, so the last subnet CIDR in the
    prefix is used as a base CIDR for creating public subnets.
  */
  public_subnet_base_cidr    = cidrsubnet(var.vpc_cidr, 2, length(var.az_names))
  nat_gateway_resource_count = var.enable_nat_gateway ? length(var.az_names) : 0
}

###############################
#  VPC
###############################

resource aws_vpc default {
  cidr_block            = var.vpc_cidr
  enable_dns_support    = true
  enable_dns_hostnames  = true
  tags                  = var.tags
}

###############################
#  Private Subnets
###############################

resource aws_subnet private {
  vpc_id                = aws_vpc.default.id
  cidr_block            = cidrsubnet(var.vpc_cidr, 2, count.index)
  availability_zone     = element(var.az_names, count.index)
  tags                  = local.subnet_tags

  count                 = length(var.az_names)
}

###############################
#  Public Subnets
###############################

resource aws_subnet public {
  vpc_id                = aws_vpc.default.id
  cidr_block            = cidrsubnet(local.public_subnet_base_cidr, 2, count.index)
  availability_zone     = element(var.az_names, count.index)
  tags                  = local.subnet_tags

  count                 = length(var.az_names)
}

###############################
#  Internet Gateway
###############################

resource aws_internet_gateway igw {
  vpc_id = aws_vpc.default.id

  tags   = var.tags
}

###############################
#  NAT Gateway
###############################

resource aws_eip ngw {
  vpc        = true
  tags       = var.tags

  count      = local.nat_gateway_resource_count
  depends_on = [aws_internet_gateway.igw]
}

resource aws_nat_gateway ngw {
  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = var.tags

  count         = local.nat_gateway_resource_count
  depends_on    = [aws_internet_gateway.igw]
}

###############################
#  Private Routes
###############################

resource aws_route_table private {
  vpc_id = aws_vpc.default.id
  tags   = var.tags

  count  = length(var.az_names)
}

resource aws_route_table_association private_subnets {
  route_table_id = aws_route_table.private[count.index].id
  subnet_id      = aws_subnet.private[count.index].id

  count          = length(var.az_names)
}

resource aws_route private_nat {
  route_table_id         = aws_route_table.private[count.index].id
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
  destination_cidr_block = "0.0.0.0/0"

  count                  = local.nat_gateway_resource_count
}

###############################
#  Public Routes
###############################

resource aws_route_table public {
  vpc_id = aws_vpc.default.id
  tags   = var.tags

  count  = length(var.az_names)
}

resource aws_route_table_association public_subnets {
  route_table_id = aws_route_table.public[count.index].id
  subnet_id      = aws_subnet.public[count.index].id

  count          = length(var.az_names)
}

resource aws_route public_igw {
  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"

  count                  = length(var.az_names)
}
