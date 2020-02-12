locals {
  bastion_iam_role_name           = "${var.resource_prefix}-bastion"
  inbound_nginx_iam_role_name     = "${var.resource_prefix}-in-nginx"
  outbound_nginx_iam_role_name    = "${var.resource_prefix}-out-nginx"
  xray_write_access_arn           = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  dynamodb_stream_read_access_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}
