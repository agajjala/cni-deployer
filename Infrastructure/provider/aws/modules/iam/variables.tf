variable region {
  type = string
}
variable resource_prefix {
  type = string
}
variable tags {
  type = map(string)
}
variable private_connect_role_name {
  description = "Name to use for the customer-facing Private Connect IAM role"
  type        = string
  default     = ""
}
variable api_authorizer_c2c_key_secret_name {
  description = "Name of the secret containing the C2C key used by the API Gateway authorizer"
  type        = string
}
variable monitoring_s3_bucket {
  type = object({
    arn = string
  })
}
