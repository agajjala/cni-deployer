###############################
#  KMS Key
###############################

module bucket_key {
  source          = "../kms_key"
  tags            = var.tags
  admin_role_arn  = var.admin_role_arn
  enable_alias    = true
  alias_name      = var.bucket_name
}

###############################
#  Bucket
###############################

resource aws_s3_bucket bucket {
  bucket = var.bucket_name
  acl    = "private"
  policy = data.aws_iam_policy_document.bucket_policy.json
  region = var.region
  tags   = var.tags

  versioning {
    enabled    = true
    mfa_delete = var.enable_mfa_delete
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = module.bucket_key.key_id
        sse_algorithm     = "aws:kms"
      }
    }
  }

  logging {
    target_bucket = var.access_log_bucket_name
    target_prefix = "${var.bucket_name}/"
  }
}

###############################
#  Bucket Policy
###############################

data aws_iam_policy_document bucket_policy {
  statement {
    sid    = "RequireEncryptionInTransit"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = [
        "*"
      ]
    }

    actions = [
      "s3:*"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    condition {
      test     = "Bool"
      values   = [
        "false"
      ]
      variable = "aws:SecureTransport"
    }
  }

  statement {
    sid    = "RequireKMSEncryption"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = [
        "*"
      ]
    }

    actions = [
      "s3:PutObject"
    ]
    resources = [
      "arn:aws:s3:::${var.bucket_name}/*"
    ]

    condition {
      test     = "Null"
      values   = [
        "false"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }

    condition {
      test     = "StringNotEquals"
      values   = [
        "aws:kms"
      ]
      variable = "s3:x-amz-server-side-encryption"
    }
  }

  # TODO: Revisit why this statement results in access denied errors when attempting CreateMultipartUpload
//  statement {
//    sid    = "RequireKMSEncryptionWithSpecificKey"
//    effect = "Deny"
//
//    principals {
//      type        = "*"
//      identifiers = [
//        "*"
//      ]
//    }
//
//    actions = [
//      "s3:PutObject"
//    ]
//    resources = [
//      "arn:aws:s3:::${var.bucket_name}/*"
//    ]
//
//    condition {
//      test     = "StringEquals"
//      values   = [
//        "aws:kms"
//      ]
//      variable = "s3:x-amz-server-side-encryption"
//    }
//
//    condition {
//      test     = "StringNotEquals"
//      values   = [
//        module.bucket_key.key_id
//      ]
//      variable = "s3:x-amz-server-side-encryption-aws-kms-key-id"
//    }
//  }
}
