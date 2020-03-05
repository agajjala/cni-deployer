variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_id {}
variable sfdc_cidr_blocks {
  type = list(string)
}
variable endpoint_ingress_port_from {
  description = "The starting port to allow ingress traffic for private endpoints"
  type        = number
}
variable endpoint_ingress_port_to {
  description = "The ending port to allow ingress traffic for private endpoints"
  type        = number
}
