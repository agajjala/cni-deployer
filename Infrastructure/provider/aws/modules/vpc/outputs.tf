output vpc_id {
  value = aws_vpc.default.id
}

output vpc_cidr {
  value = aws_vpc.default.cidr_block
}

output private_subnet_ids {
  value = aws_subnet.private.*.id
}

output public_subnet_ids {
  value = aws_subnet.public.*.id
}
