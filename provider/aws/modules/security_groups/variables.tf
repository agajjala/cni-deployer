variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_id {}
variable vpc_type {}
variable sfdc_cidr_blocks {
  type = list(string)
}
