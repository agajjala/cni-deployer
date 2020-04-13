output aws_instance_ids {
  value = aws_instance.instance.*.id
}
