variable image_id {}
variable instance_type {}
variable vpc_id {}
variable subnet_id {}
variable ec2_key_name {}
variable tags {
  type = map(string)
}
variable vpc_security_group_ids {
  type = list(string)
}
