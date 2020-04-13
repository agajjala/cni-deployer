variable image_id {}
variable instance_type {}
variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable vpc_cidr {}
variable private_subnet_cidrs {
  type    = list(string)
  default = []
}
variable public_subnet_cidrs {
  type    = list(string)
  default = []
}
variable sfdc_cidr_blocks {
  type = list(string)
}
variable kaiju_agent_cidrs {
  type = list(string)
}
variable az_count {
  type = number
}
variable az_names {
  type = list(string)
}
variable enable_nat_gateway {
  type    = bool
  default = false
}
variable enable_private_nat_routes {
  type    = bool
  default = false
}
variable zone_name {}
variable admin_role_arns {
  type = list(string)
}
variable flow_log_retention_in_days {}
variable flow_log_iam_role_arn {}
variable transit_gateway_id {}
variable endpoint_ingress_port_from {
  description = "The starting port to allow ingress traffic for private endpoints"
  type        = number
}
variable endpoint_ingress_port_to {
  description = "The ending port to allow ingress traffic for private endpoints"
  type        = number
}
variable key_name {}
variable iam_instance_profile_name {}
variable docker_image_id {}
