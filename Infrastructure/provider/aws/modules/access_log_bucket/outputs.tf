output bucket {
  value = aws_s3_bucket.bucket
}

output bucket_name {
  value = aws_s3_bucket.bucket.id
}
