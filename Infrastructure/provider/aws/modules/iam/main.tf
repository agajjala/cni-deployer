locals {
  bastion_iam_role_name           = "${var.resource_prefix}-bastion"
  inbound_nginx_iam_role_name     = "${var.resource_prefix}-in-nginx"
  outbound_nginx_iam_role_name    = "${var.resource_prefix}-out-nginx"
  monitoring_ec2_iam_role_name    = "${var.resource_prefix}-monitoring-ec2"
  xray_write_policy_arn           = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess"
  lambda_basic_execution_role_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  lambda_dynamodb_stream_read_policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaDynamoDBExecutionRole"
}
