variable "region" {}
variable "access_key" {}
variable "secret_key" {}

variable "deployment_id" {}

variable "tags" {
  type = "map"
}
variable "vpc_cidr_block" {}
variable "sfdc_cidr" {}
variable "public_subnet_count" {}
variable "public_subnet_cidr_blocks" {
  type = "list"
}
variable "public_subnet_availability_zone_ids" {
  type = "list"
}

variable "private_subnet_count" {}
variable "private_subnet_cidr_blocks" {
  type = "list"
}
variable "private_subnet_availability_zone_ids" {
  type = "list"
}
variable "inbound_zone_name" {}
variable "zone_name" {}
variable "flow_logs_retention_in_days" {}
