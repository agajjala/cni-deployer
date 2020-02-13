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
  source                            = "../modules/globals"
  region                            = var.region
  resource_prefix                   = local.resource_prefix
  tags                              = var.tags
  admin_role_arn                    = local.admin_role_arn
  flow_logs_retention_in_days       = var.flow_logs_retention_in_days
  artifact_bucket                   = var.artifact_bucket
  lambda_layer_s3_key               = var.lambda_layer_s3_key
  lambda_layer_s3_object_version    = var.lambda_layer_s3_object_version
  lambda_function_s3_key            = var.lambda_function_s3_key
  lambda_function_s3_object_version = var.lambda_function_s3_object_version
  lambda_memory_size                = var.lambda_memory_size
}

module transit_gateway {
  source = "../modules/tgw"
  tags   = var.tags
  name   = local.resource_prefix
}

module bastion_key_pair {
  source                = "../modules/ec2_key_pair"
  key_name              = "${local.resource_prefix}-bastion"
  write_local_pem_file  = var.write_local_pem_files
}

module node_group_key_pair {
  source                = "../modules/ec2_key_pair"
  key_name              = "${local.resource_prefix}-node-group"
  write_local_pem_file  = var.write_local_pem_files
}

module inbound_vpc {
  source                             = "../modules/traffic_vpc"
  region                             = var.region
  resource_prefix                    = local.resource_prefix
  tags                               = var.tags
  vpc_type                           = "inbound"
  vpc_cidr                           = var.inbound_vpc_cidr
  sfdc_cidr_blocks                   = var.sfdc_vpn_cidrs
  az_names                           = local.az_names
  enable_nat_gateway                 = var.enable_inbound_nat_gateway
  zone_name                          = "cni-inbound.salesforce.com"
  admin_role_arn                     = local.admin_role_arn
  flow_log_iam_role_arn              = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days         = var.flow_logs_retention_in_days
  data_plane_cluster_role_arn        = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name       = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn           = module.globals.data_plane_node_role_arn
  data_plane_node_role_name          = module.globals.data_plane_node_role_name
  transit_gateway_id                 = module.transit_gateway.tgw_id
  bastion_autoscaling_group_role_arn = module.globals.bastion_autoscaling_group_role_arn
  bastion_instance_profile_arn       = module.globals.bastion_instance_profile_arn
  bastion_image_id                   = data.aws_ami.bastion_image_id.id
  bastion_key_name                   = module.bastion_key_pair.key_name
  node_group_key_name                = module.node_group_key_pair.key_name
}

module outbound_vpc {
  source                             = "../modules/traffic_vpc"
  region                             = var.region
  resource_prefix                    = local.resource_prefix
  tags                               = var.tags
  vpc_type                           = "outbound"
  vpc_cidr                           = var.inbound_vpc_cidr
  sfdc_cidr_blocks                   = var.sfdc_vpn_cidrs
  az_names                           = local.az_names
  enable_nat_gateway                 = var.enable_inbound_nat_gateway
  zone_name                          = "cni-outbound.salesforce.com"
  admin_role_arn                     = local.admin_role_arn
  flow_log_iam_role_arn              = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days         = var.flow_logs_retention_in_days
  data_plane_cluster_role_arn        = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name       = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn           = module.globals.data_plane_node_role_arn
  data_plane_node_role_name          = module.globals.data_plane_node_role_name
  transit_gateway_id                 = module.transit_gateway.tgw_id
  bastion_autoscaling_group_role_arn = module.globals.bastion_autoscaling_group_role_arn
  bastion_instance_profile_arn       = module.globals.bastion_instance_profile_arn
  bastion_image_id                   = data.aws_ami.bastion_image_id.id
  bastion_key_name                   = module.bastion_key_pair.key_name
  node_group_key_name                = module.node_group_key_pair.key_name
}
