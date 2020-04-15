variable region {}
variable env_name {}
variable deployment_id {}
variable tags {
  type = map(string)
}
variable admin_role_names {
  type = list(string)
  default = [
    "PCSKAdministratorAccessRole"
  ]
}
variable force_destroy_state_bucket {
  description = "If true, deletion of the bucket will result in deletion of all bucket objects"
  type        = bool
  default     = false
}
