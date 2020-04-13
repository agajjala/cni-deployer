output vpc_id {
  value = aws_vpc.default.id
}

output vpc {
  value = aws_vpc.default
}

output vpc_cidr {
  value = aws_vpc.default.cidr_block
}

output private_subnet_ids {
  value = aws_subnet.private.*.id
}

output private_subnets {
  value = aws_subnet.private.*
}

output public_subnet_ids {
  value = aws_subnet.public.*.id
}

output public_subnets {
  value = aws_subnet.public.*
}

output private_route_table_ids {
  value = aws_route_table.private.*.id
}
