data aws_caller_identity current {}

data aws_secretsmanager_secret_version github_oauth_token {
  secret_id = local.git_token_secret_id
}

data github_repository manifest {
  full_name = "${local.repo_org}/${local.repo_name}"
}

data aws_s3_bucket state_bucket {
  bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
}

data terraform_remote_state region_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "region_base"
    region = var.region
  }
}

data aws_dynamodb_table tf_state_lock {
  name = "tf-state-lock"
}
