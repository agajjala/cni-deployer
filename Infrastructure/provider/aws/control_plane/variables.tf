variable env_name {}
variable region {}
variable deployment_id {}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
}
variable api_access_whitelist_ips {
  description = "List of IPs to whitelist network traffic to the control plane API Gateway"
  type        = list(string)
  default     = []
}
variable api_dev_access_whitelist {
  description = "List of DEV SFDC VPN IPs to whitelist network traffic to the control plane API Gateway"
  type        = list(string)
  default = [
    # PRD
    "136.146.95.8/32",
    # AmerWest
    "204.14.239.17/32",
    "204.14.239.18/32",
    "204.14.239.13/32",
    "204.14.239.105/32",
    "204.14.239.106/32",
    "204.14.239.107/32",
    "204.14.239.82/32",
    # AmerWest1
    "13.110.54.0/26",
    # AmerEast
    "204.14.236.215/32",
    "204.14.236.150/32",
    "204.14.236.152/32",
    "204.14.236.153/32",
    "204.14.236.154/32",
    "204.14.236.219/32",
    "204.14.236.218/32",
  "204.14.236.212/32"]
}
variable api_prod_access_whitelist {
  description = "List of PROD SFDC IPs to whitelist network traffic to the control plane API Gateway"
  type        = list(string)
  default = [
    # PRD
    "136.146.95.8/32",
    # PHX
    "136.147.46.8/32",
    # DFW
    "136.147.62.8/32",
    # IAD
    "13.108.238.8/32",
    # PH2
    "13.110.6.8/32",
    # IA2
    "13.110.14.8/32",
    # ORD
    "13.108.254.8/32",
    # IA4
    "13.110.74.8/32",
    # IA5
  "13.110.78.8/32"]
}
variable api_authorization {
  description = "Type of API Gateway authorization to use"
  type        = string
  default     = "CUSTOM"
}
variable api_authorizer_gdot_url {
  description = "URL of the GDOT endpoint to use for the API Gateway authorizer"
  type        = string
}
variable api_authorizer_c2c_key_secret_name {
  description = "Name of the C2C key secret in Secrets Manager"
  type        = string
}
variable lambda_layer_s3_key {
  description = "Name of the lambda layer object in the S3 bucket"
  type        = string
}
variable lambda_function_s3_key {
  description = "Path to the function artifact in the S3 bucket"
  type        = string
}
variable lambda_runtime {
  description = "Runtime to use for endpoint functions"
  type        = string
  default     = "python3.7"
}
variable lambda_memory_size {
  description = "Memory to allocate to endpoint functions in MB"
  type        = number
}
variable lambda_timeout {
  description = "Timeout in seconds for each function invocation"
  type        = number
  default     = 300
}
variable lambda_provisioned_concurrent_executions {
  description = "Number of concurrent execution environments to keep warm for each endpoint function"
  type        = number
  default     = 0
}
variable enable_sitebridge {
  description = "If false, skips creating resources related to Sitebridge."
  type        = bool
  default     = true
}
variable vpc_suffix {
  description = "Suffix of the outbound VPC"
  type        = string
}
