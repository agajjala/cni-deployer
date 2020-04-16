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
  type = string
  default = ""
}
variable monitoring_s3_bucket {
  type = object({
    arn = string
  })
}
