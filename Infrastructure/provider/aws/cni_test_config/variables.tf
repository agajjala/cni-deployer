variable region {}
variable env_name {}
variable deployment_id {}
variable tags {
  type = map(string)
}
variable inbound_service_name {
  default = "nginx-dp"
}
variable inbound_api_key {}
variable outbound_service_name {
  default = "nginx-dp"
}
variable outbound_api_key {}
