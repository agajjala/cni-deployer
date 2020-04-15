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

data terraform_remote_state region_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "region_base"
    region = var.region
  }
}

data terraform_remote_state stack_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/stack_base"
    region = var.region
  }
}
