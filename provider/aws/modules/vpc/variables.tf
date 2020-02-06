variable tags {
  type = map(string)
}
variable vpc_name {}
variable vpc_cidr {}
variable additional_vpc_tags {
  type    = map(string)
  default = {}
}
variable additional_subnet_tags {
  type    = map(string)
  default = {}
}
variable az_names {
  type        = list(string)
  description = "A list of availability zone names. Must be three or fewer."
}
variable enable_nat_gateway {
  type    = bool
  default = false
}
