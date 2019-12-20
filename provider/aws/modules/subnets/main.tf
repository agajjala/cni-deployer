resource "aws_subnet" "public" {
  vpc_id                = "${var.vpc_id}"
  cidr_block            = "${element(var.public_subnet_cidr_blocks, count.index)}"
  availability_zone_id  = "${element(var.public_subnet_availability_zone_ids, count.index)}"

  tags                  = "${var.tags}"

  count                 = "${var.public_subnet_count}"
}

resource "aws_subnet" "private" {
  vpc_id                = "${var.vpc_id}"
  cidr_block            = "${element(var.private_subnet_cidr_blocks, count.index)}"
  availability_zone_id  = "${element(var.private_subnet_availability_zone_ids, count.index)}"

  tags                  = "${var.tags}"

  count                 = "${var.private_subnet_count}"
}
