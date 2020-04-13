locals {
  gateway_ips_without_suffix = [for str in var.gateway_ips: trimsuffix(str, "/32")]
}
