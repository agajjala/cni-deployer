variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type = map(string)
}
variable bucket_name {
  description = "Name of this S3 bucket"
  type        = string
}
variable region {
  description = "Region the bucket should be created in"
  type        = string
}
variable enable_logging_bucket_expiration {
  description = "If true, enables expiration of bucket objects and object versions"
  type        = bool
  default     = true
}
variable logging_bucket_version_expiration {
  description = "The time in days before an object version should be deleted from the bucket"
  type        = number
  default     = 90
}
variable logging_bucket_object_expiration {
  description = "The time in days before an object should be deleted from the bucket"
  type        = number
  default     = 90
}
