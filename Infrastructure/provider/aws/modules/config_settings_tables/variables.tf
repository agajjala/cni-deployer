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
variable inbound_zone {
  description = "Hosted zone of the inbound data plane"
  type = object({
    id   = string
    name = string
  })
}
variable inbound_vpc_endpoint_service {
  description = "VPC endpoint service for the inbound data plane"
  type = object({
    id           = string
    service_name = string
  })
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
variable outbound_vpc {
  description = "VPC of the outbound data plane"
  type = object({
    id = string
  })
}
variable outbound_vpce_connections_topic {
  description = "SNS topic for outbound VPC endpoint connection events"
  type = object({
    arn = string
  })
}
variable outbound_private_subnets {
  description = "List of private subnets for the outbound data plane"
  type = list(object({
    id = string
  }))
}
variable outbound_proxy_domain_name {
  description = "Domain name used by customers to reach the outbound proxy"
  type = string
}
variable nginx_sg {
  description = "Security group attached to NGINX hosts in the outbound data plane"
  type = object({
    id = string
  })
}
