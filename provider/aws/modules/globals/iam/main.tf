locals {
  inbound_bastion_iam_role_name  = "${var.resource_prefix}-in-bastion"
  outbound_bastion_iam_role_name = "${var.resource_prefix}-out-bastion"
  inbound_nginx_iam_role_name  = "${var.resource_prefix}-in-nginx"
  outbound_nginx_iam_role_name = "${var.resource_prefix}-out-nginx"
}