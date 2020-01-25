terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = "${var.env_name}-${var.deployment_id}"
}

module globals {
  source                      = "../modules/globals"
  region                      = var.region
  resource_prefix             = local.resource_prefix
  tags                        = var.tags
  admin_role_name             = var.admin_role_name
  flow_logs_retention_in_days = var.flow_logs_retention_in_days
}

module inbound_vpc {
  source                         = "../modules/inbound_vpc"
  region                         = var.region
  resource_prefix                = local.resource_prefix
  tags                           = var.tags
  vpc_cidr                       = var.inbound_vpc_cidr
  sfdc_cidr_blocks               = var.sfdc_vpn_cidrs
  az_count                       = var.az_count
  zone_name                      = "cni-inbound.salesforce.com"
  flow_logs_cloudwatch_group_arn = module.globals.cloudwatch_log_group_inbound_flow_logs_arn
  flow_logs_iam_role_arn         = module.globals.iam_role_flow_logs_arn
}

module outbound_vpc {
  source                         = "../modules/outbound_vpc"
  region                         = var.region
  env_name                       = var.env_name
  resource_prefix                = local.resource_prefix
  tags                           = var.tags
  vpc_cidr                       = var.outbound_vpc_cidr
  sfdc_cidr_blocks               = var.sfdc_vpn_cidrs
  az_count                       = var.az_count
  zone_name                      = "cni-outbound.salesforce.com"
  flow_logs_cloudwatch_group_arn = module.globals.cloudwatch_log_group_outbound_flow_logs_arn
  flow_logs_iam_role_arn         = module.globals.iam_role_flow_logs_arn
}
