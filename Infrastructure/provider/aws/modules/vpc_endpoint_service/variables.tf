variable tags {
  type = map(string)
}
variable require_acceptance {
  type    = bool
  default = true
}
variable nlb_arn {}
variable vpce_connections_topic_arn {}
