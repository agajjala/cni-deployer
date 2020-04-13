output key {
  value = aws_kms_key.default
}

output key_id {
  value = aws_kms_key.default.key_id
}

output key_arn {
  value = aws_kms_key.default.arn
}
