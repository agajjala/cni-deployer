resource aws_s3_bucket bucket {
  tags          = var.tags
  bucket        = var.bucket_name
  acl           = "log-delivery-write"
  policy        = data.aws_iam_policy_document.bucket_policy.json
  region        = var.region
  force_destroy = var.force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "DefaultRetentionStrategy"
    enabled = var.enable_logging_bucket_expiration

    noncurrent_version_expiration {
      days = var.logging_bucket_version_expiration
    }

    expiration {
      days = var.logging_bucket_object_expiration
    }
  }
}

data aws_iam_policy_document bucket_policy {
  statement {
    sid    = "RequireEncryptionInTransit"
    effect = "Deny"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}
