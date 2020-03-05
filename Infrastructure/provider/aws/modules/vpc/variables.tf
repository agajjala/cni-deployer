variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable vpc_name {}
variable vpc_cidr {}
variable vpc_tags {
  type    = map(string)
  default = {}
}
variable private_subnet_tags {
  type    = map(string)
  default = {}
}
variable public_subnet_tags {
  type    = map(string)
  default = {}
}
variable private_subnet_cidrs {
  type = list(string)
}
variable public_subnet_cidrs {
  type = list(string)
}
variable az_names {
  type        = list(string)
  description = "A list of availability zone names. Must be three or fewer."
}
variable enable_nat_gateway {
  type    = bool
  default = false
}
variable enable_private_nat_routes {
  type    = bool
  default = false
}
