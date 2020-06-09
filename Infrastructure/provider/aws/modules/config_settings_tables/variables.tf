variable tags {
  type = map(string)
}
variable resource_prefix {}
variable enable_point_in_time_recovery {
  type    = bool
  default = true
}
variable api_key {
  description = "API key used for authenticating to the authorizer"
  type        = string
}
variable private_link_access_role {
  description = "TBD"
  type = object({
    arn = string
  })
}
variable outbound_zone {
  description = "Hosted zone of the outbound data plane"
  type = object({
    id   = string
    name = string
  })
}
variable outbound_vpce_connections_topic {
  description = "SNS topic for outbound VPC endpoint connection events"
  type = object({
    arn = string
  })
}
