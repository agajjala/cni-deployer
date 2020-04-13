locals {
  pem_file_path = "${path.root}/${var.key_name}.pem"
}

resource tls_private_key private_key {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource aws_key_pair generated_key {
  tags = var.tags
  key_name   = var.key_name
  public_key = tls_private_key.private_key.public_key_openssh
}

resource aws_secretsmanager_secret secret {
  tags = var.tags
  name_prefix = var.key_name
  recovery_window_in_days = 0
}

resource aws_secretsmanager_secret_version secret_value {
  secret_id     = aws_secretsmanager_secret.secret.arn
  secret_string = tls_private_key.private_key.private_key_pem
}

resource local_file pem_file {
  content   = tls_private_key.private_key.private_key_pem
  filename  = local.pem_file_path

  count     = var.write_local_pem_file ? 1 : 0

  provisioner "local-exec" {
    command = "chmod 600 ${local.pem_file_path}"
  }
}
