module iam {
  source                       = "./iam"
  region                       = var.region
  resource_prefix              = var.resource_prefix
  tags                         = var.tags
  inbound_nginx_ecr_repo_arn   = var.inbound_nginx_ecr_repo_arn
  inbound_nginx_s3_bucket_arn  = var.inbound_nginx_s3_bucket_arn
  outbound_nginx_ecr_repo_arn  = var.outbound_nginx_ecr_repo_arn
  outbound_nginx_s3_bucket_arn = var.outbound_nginx_s3_bucket_arn
}

module sns {
  source          = "./sns"
  region          = var.region
  resource_prefix = var.resource_prefix
  tags            = var.tags
  admin_role_arn  = var.admin_role_arn
}

# TODO: use global tables
module dynamodb {
  source          = "./dynamodb"
  resource_prefix = var.resource_prefix
  tags            = var.tags
}

module lambda {
  source                                        = "./lambda"
  resource_prefix                               = var.resource_prefix
  tags                                          = var.tags
  bucket_name                                   = var.bucket_name
  layer_s3_key                                  = var.lambda_layer_s3_key
  layer_s3_object_version                       = var.lambda_layer_s3_object_version
  function_s3_key                               = var.lambda_function_s3_key
  function_s3_object_version                    = var.lambda_function_s3_object_version
  memory_size                                   = var.lambda_memory_size
  inbound_private_link_event_handler_role_arn   = module.iam.ctrl_inbound_private_link_event_handler_role_arn
  inbound_private_link_stream_role_name         = module.iam.ctrl_inbound_private_link_stream_role_name
  outbound_private_link_event_handler_role_arn  = module.iam.ctrl_outbound_private_link_event_handler_role_arn
  outbound_private_link_stream_role_name        = module.iam.ctrl_outbound_private_link_stream_role_name
  inbound_supervisor_role_arn                   = module.iam.ctrl_inbound_supervisor_role_arn
  inbound_private_link_api_endpoint_role_arn    = module.iam.ctrl_inbound_private_link_api_endpoint_role_arn
  outbound_supervisor_role_arn                  = module.iam.ctrl_outbound_supervisor_role_arn
  outbound_private_link_api_endpoint_role_arn   = module.iam.ctrl_outbound_private_link_api_endpoint_role_arn
  dynamodb_stream_fanout_role_arn               = module.iam.ctrl_dynamodb_stream_fanout_role_arn
  dynamodb_stream_fanout_role_name              = module.iam.ctrl_dynamodb_stream_fanout_role_name
  inbound_private_link_stream_role_arn          = module.iam.ctrl_inbound_private_link_stream_role_arn
  outbound_private_link_stream_role_arn         = module.iam.ctrl_outbound_private_link_stream_role_arn
  inbound_private_link_stream_arn               = module.dynamodb.inbound_private_links_stream_arn
  outbound_private_link_stream_arn              = module.dynamodb.outbound_private_links_stream_arn
  inbound_vpce_connections_topic_arn            = module.sns.inbound_vpce_connections_topic_arn
  inbound_vpce_connections_kms_key_arn          = module.sns.inbound_vpce_connections_kms_key_arn
  outbound_vpce_connections_topic_arn           = module.sns.outbound_vpce_connections_topic_arn
  outbound_vpce_connections_kms_key_arn         = module.sns.outbound_vpce_connections_kms_key_arn
  dynamodb_stream_fanout_topic_arn              = module.sns.dynamodb_stream_fanout_topic_arn
  dynamodb_stream_fanout_kms_key_arn            = module.sns.dynamodb_stream_fanout_kms_key_arn
}

module api_gateway {
  source                                = "./api_gateway"
  resource_prefix                       = var.resource_prefix
  tags                                  = var.tags
  info_inbound_get_lambda               = module.lambda.info_inbound_get_lambda
  info_outbound_get_lambda              = module.lambda.info_outbound_get_lambda
  privatelinks_inbound_get_lambda       = module.lambda.privatelinks_inbound_get_lambda
  privatelinks_inbound_get_one_lambda   = module.lambda.privatelinks_inbound_get_one_lambda
  privatelinks_inbound_update_lambda    = module.lambda.privatelinks_inbound_update_lambda
  privatelinks_inbound_delete_lambda    = module.lambda.privatelinks_inbound_delete_lambda
  privatelinks_outbound_get_lambda      = module.lambda.privatelinks_outbound_get_lambda
  privatelinks_outbound_create_lambda   = module.lambda.privatelinks_outbound_create_lambda
  privatelinks_outbound_get_one_lambda  = module.lambda.privatelinks_outbound_get_one_lambda
  privatelinks_outbound_delete_lambda   = module.lambda.privatelinks_outbound_delete_lambda
  privatelinks_outbound_update_lambda   = module.lambda.privatelinks_outbound_update_lambda
  privatelinks_inbound_retry_lambda     = module.lambda.privatelinks_inbound_retry_lambda
  privatelinks_outbound_retry_lambda    = module.lambda.privatelinks_outbound_retry_lambda
}
