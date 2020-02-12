variable key_name {
  description = "Name to assign the key pair in EC2"
}
variable write_local_pem_file {
  description = "If true, writes the private key as a local pem file in the directory of the root module"
  type        = bool
  default     = false
}