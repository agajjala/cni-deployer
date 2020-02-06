locals {
  lambda_invocation_method = "POST"
}

resource aws_api_gateway_rest_api controller {
  name = "${var.resource_prefix}-controller"
  tags = var.tags
}

module v1 {
  source                               = "./v1"
  api_id                               = aws_api_gateway_rest_api.controller.id
  root_resource_id                     = aws_api_gateway_rest_api.controller.root_resource_id
  execution_arn                        = aws_api_gateway_rest_api.controller.execution_arn
  lambda_invocation_method             = local.lambda_invocation_method
  info_inbound_get_lambda              = var.info_inbound_get_lambda
  info_outbound_get_lambda             = var.info_outbound_get_lambda
  privatelinks_inbound_get_lambda      = var.privatelinks_inbound_get_lambda
  privatelinks_inbound_get_one_lambda  = var.privatelinks_inbound_get_one_lambda
  privatelinks_inbound_update_lambda   = var.privatelinks_inbound_update_lambda
  privatelinks_inbound_delete_lambda   = var.privatelinks_inbound_delete_lambda
  privatelinks_outbound_get_lambda     = var.privatelinks_outbound_get_lambda
  privatelinks_outbound_create_lambda  = var.privatelinks_outbound_create_lambda
  privatelinks_outbound_get_one_lambda = var.privatelinks_outbound_get_one_lambda
  privatelinks_outbound_update_lambda  = var.privatelinks_outbound_update_lambda
  privatelinks_outbound_delete_lambda  = var.privatelinks_outbound_delete_lambda
}
