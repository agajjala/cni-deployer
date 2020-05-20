variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable region {
  description = "Region the bucket should be created in"
  type        = string
}
variable admin_principals {
  description = ""
  type        = list(string)
}
variable bucket_name {
  description = "Name of this S3 bucket"
  type        = string
}
variable enable_versioning {
  description = "If true, enables versioning on bucket objects"
  type        = bool
  default     = true
}
variable enable_mfa_delete {
  description = "If true, enables MFA delete on bucket object versions"
  type        = bool
  default     = true
}
variable access_log_bucket_name {
  description = "Name of the S3 bucket used for logging access requests to this bucket"
  type        = string
  default     = ""
}
variable force_destroy {
  description = "If true, deletion of the bucket will result in deletion of all bucket objects"
  type        = bool
  default     = false
}
