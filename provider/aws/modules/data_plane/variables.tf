variable resource_prefix {}
variable tags {
  type = map(string)
}
variable cluster_name {}
variable admin_role_arn {}
variable data_plane_cluster_role_arn {}
variable data_plane_cluster_role_name {}
variable data_plane_node_role_arn {}
variable data_plane_node_role_name {}
variable retention_in_days {}
variable subnet_ids {
  type = list(string)
}
variable security_group_ids {
  type = list(string)
}
variable public_access_cidrs {
  type = list(string)
}
variable enabled_cluster_log_types {
  type = list(string)
  default = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler"
  ]
}
variable scaling_config {
  type = object({
    desired_size = number,
    max_size     = number,
    min_size     = number
  })
}
variable bastion_sg_id {}
