data aws_caller_identity current {}

data aws_availability_zones available {
  state = "available"
}

data aws_ami bastion_image_id {
  owners = ["aws-marketplace"]

  filter {
    name   = "description"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA 1805_01"]
  }
}
