variable "tags" {
  type = map(string)
}
variable "vpc_id" {}
variable "igw_id" {}
variable "ngw_id" {}
variable "public_subnet_ids" {
  type = list(string)
}
variable "private_subnet_ids" {
  type = list(string)
}
