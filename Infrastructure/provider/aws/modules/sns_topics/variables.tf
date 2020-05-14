variable region {}
variable resource_prefix {}
variable tags {
  type = map(string)
}
variable admin_principals {
  type = list(string)
}
variable private_connect_role {
  type = object({
    arn = string
  })
}
variable private_link_event_handler_role {
  type = object({
    arn = string
  })
}
variable private_link_stream_role {
  type = object({
    arn = string
  })
}
