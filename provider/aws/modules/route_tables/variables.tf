variable "tags" {
  type = "map"
}
variable "vpc_id" {}
variable "igw_id" {}
variable "ngw_id" {}
variable "public_subnet_ids" {
  type = "list"
}
variable "public_subnet_count" {}
variable "private_subnet_ids" {
  type = "list"
}
variable "private_subnet_count" {}
