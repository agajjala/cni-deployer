variable resource_prefix {}
variable tags {
  type = map(string)
}
variable enable_point_in_time_recovery {
  type    = bool
  default = true
}
