resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags   = "${var.tags}"
}

resource "aws_eip" "nat" {
  vpc        = "true"

  tags       = "${var.tags}"

  depends_on = ["aws_internet_gateway.igw"]
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${var.nat_gateway_subnet_id}"

  tags          = "${var.tags}"

  depends_on    = ["aws_internet_gateway.igw"]
}
