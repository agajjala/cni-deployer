/*
  After the first run of this module, the dummy backend file is made into a proper .tf file to be
  used in subsequent runs.

  On the second run, Terraform will prompt to migrate existing state to the s3 backend defined in
  backend.tf. Give affirmation to this prompt. The state for resources related to state management
  will then be stored in s3.
*/

provider aws {
  region = var.region
}

locals {
  admin_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
  bucket_name     = "tf-state-${var.project_name}-${var.env_name}-${var.deployment_id}"
  lock_table_name = "tf-state-${var.project_name}-${var.env_name}-${var.deployment_id}"
}

module state_bucket_key {
  source          = "../modules/kms_key"
  tags            = var.tags
  key_name        = local.bucket_name
  admin_role_arn  = local.admin_role_arn
}

resource aws_s3_bucket state_bucket {
  bucket = local.bucket_name
  acl    = "private"

//  lifecycle {
//    prevent_destroy = true
//  }

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.state_bucket_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  tags = var.tags
}

resource aws_dynamodb_table lock_table {
  name           = local.lock_table_name
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "LockID"

  //  lifecycle {
  //    prevent_destroy = true
  //  }

  server_side_encryption {
    enabled = true
  }

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = var.tags
}

resource null_resource s3_backend {
  provisioner "local-exec" {
    command = "cp backend backend.tf"
  }
}
