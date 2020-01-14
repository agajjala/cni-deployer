output "igw_id" {
  value = aws_internet_gateway.igw.id
}

output "ngw_id" {
  value = aws_nat_gateway.ngw.id
}
