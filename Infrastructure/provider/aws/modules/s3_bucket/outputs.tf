output bucket {
  value = aws_s3_bucket.bucket
}

output bucket_key {
  value = module.bucket_key.key
}
