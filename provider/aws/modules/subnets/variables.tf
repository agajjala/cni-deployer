variable "tags" {
  type = "map"
}
variable "vpc_id" {}
variable "public_subnet_cidr_blocks" {
  type = "list"
}
variable "public_subnet_availability_zone_ids" {
  type = "list"
}
variable "public_subnet_count" {}
variable "private_subnet_cidr_blocks" {
  type = "list"
}
variable "private_subnet_availability_zone_ids" {
  type = "list"
}
variable "private_subnet_count" {}
