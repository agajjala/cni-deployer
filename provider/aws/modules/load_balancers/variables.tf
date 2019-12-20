variable "deployment_id" {}
variable "tags" {
  type = "map"
}
variable "vpc_id" {}
variable "vpc_type" {}
variable "private_subnet_ids" {
  type = "list"
}