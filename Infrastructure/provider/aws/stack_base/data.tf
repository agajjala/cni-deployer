data aws_caller_identity current {}

data terraform_remote_state region_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "region_base"
    region = var.region
  }
}
