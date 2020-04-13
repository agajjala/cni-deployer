output vpc {
  value = aws_vpc.zone_vpc
}

output zone {
  value = aws_route53_zone.shared_zone
}
