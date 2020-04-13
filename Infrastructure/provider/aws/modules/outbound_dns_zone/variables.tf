variable tags {
  type = map(string)
  default = {}
}
variable region {
  type = string
}
variable resource_prefix {
  type = string
}
variable vpc_cidr {
  type = string
  default = "10.0.0.0/24"
}
variable zone_name {
  type = string
}
