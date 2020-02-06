terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = "${var.env_name}-${var.region}-${var.deployment_id}"
  admin_role_arn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
  az_names        = slice(sort(data.aws_availability_zones.available.names), 0, var.az_count)
}

module globals {
  source                      = "../modules/globals"
  region                      = var.region
  resource_prefix             = local.resource_prefix
  tags                        = var.tags
  admin_role_arn              = local.admin_role_arn
  flow_logs_retention_in_days = var.flow_logs_retention_in_days
  lambda_layers               = var.lambda_layers
  lambda_s3_bucket            = var.lambda_s3_bucket
  lambda_s3_key               = var.lambda_s3_key
  lambda_memory_size          = var.lambda_memory_size
}

module transit_gateway {
  source = "../modules/tgw"
  tags   = var.tags
  name   = local.resource_prefix
}

module inbound_vpc {
  source                         = "../modules/inbound_vpc"
  region                         = var.region
  resource_prefix                = local.resource_prefix
  tags                           = var.tags
  vpc_cidr                       = var.inbound_vpc_cidr
  sfdc_cidr_blocks               = var.sfdc_vpn_cidrs
  az_names                       = local.az_names
  enable_nat_gateway             = var.enable_inbound_nat_gateway
  zone_name                      = "cni-inbound.salesforce.com"
  admin_role_arn                 = local.admin_role_arn
  flow_log_iam_role_arn          = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days     = var.flow_logs_retention_in_days
  data_plane_cluster_role_arn    = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name   = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn       = module.globals.data_plane_node_role_arn
  data_plane_node_role_name      = module.globals.data_plane_node_role_name
  scaling_config                 = var.scaling_config
  transit_gateway_id             = module.transit_gateway.tgw_id
}

module outbound_vpc {
  source                         = "../modules/outbound_vpc"
  region                         = var.region
  env_name                       = var.env_name
  resource_prefix                = local.resource_prefix
  tags                           = var.tags
  vpc_cidr                       = var.outbound_vpc_cidr
  sfdc_cidr_blocks               = var.sfdc_vpn_cidrs
  az_names                       = local.az_names
  enable_nat_gateway             = var.enable_outbound_nat_gateway
  zone_name                      = "cni-outbound.salesforce.com"
  admin_role_arn                 = local.admin_role_arn
  flow_log_iam_role_arn          = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days     = var.flow_logs_retention_in_days
  data_plane_cluster_role_arn    = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name   = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn       = module.globals.data_plane_node_role_arn
  data_plane_node_role_name      = module.globals.data_plane_node_role_name
  scaling_config                 = var.scaling_config
  transit_gateway_id             = module.transit_gateway.tgw_id
}
