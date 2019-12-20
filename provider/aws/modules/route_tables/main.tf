###############################
#  Public (starts)
###############################

resource "aws_route_table" "public" {
  vpc_id = "${var.vpc_id}"

  tags   = "${var.tags}"
}

resource "aws_route" "public_igw" {
  route_table_id         = "${aws_route_table.public.id}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public_subnets" {
  route_table_id = "${aws_route_table.public.id}"
  subnet_id      = "${element(var.public_subnet_ids, count.index)}"

  count          = "${var.public_subnet_count}"
}

###############################
#  Public (ends)
###############################

###############################
#  Private (starts)
###############################

resource "aws_route_table" "private" {
  vpc_id = "${var.vpc_id}"

  tags   = "${var.tags}"
}

resource "aws_route" "private_nat" {
  route_table_id         = "${aws_route_table.private.id}"
  nat_gateway_id         = "${aws_nat_gateway.ngw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private_subnets" {
  route_table_id = "${aws_route_table.private.id}"
  subnet_id      = "${element(var.private_subnet_ids, count.index)}"

  count          = "${var.private_subnet_count}"
}

###############################
#  Private (ends)
###############################
