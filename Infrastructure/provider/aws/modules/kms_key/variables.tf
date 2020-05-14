variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable admin_principals {
  description = "List of IAM role ARNs or ARN-like expressions to grant admin privileges on created resources"
  type        = list(string)
}
variable source_json_policy {
  description = "JSON string of inline policies to apply to the KMS key"
  default     = "{}"
}
variable enable_alias {
  description = "If true, enables additionally creating a key alias for the KMS key"
  type        = bool
  default     = false
}
variable alias_name {
  description = "Alias of the KMS key. Must be provided if enable_alias is true"
  default     = ""
}
