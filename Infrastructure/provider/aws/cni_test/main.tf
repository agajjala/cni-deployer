terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix                  = "${var.env_name}-${var.region}-${var.deployment_id}"
  admin_role_arn                   = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.admin_role_name}"
  az_names                         = slice(sort(data.aws_availability_zones.available.names), 0, var.az_count)
  inbound_vpc_resource_prefix      = "${local.resource_prefix}-inbound"
  inbound_hosted_zone_name         = "cni-inbound.salesforce.com"
  inbound_data_plane_cluster_name  = "${local.inbound_vpc_resource_prefix}-data-plane"
  outbound_vpc_resource_prefix     = "${local.resource_prefix}-outbound"
  outbound_hosted_zone_name        = "cni-outbound.salesforce.com"
  outbound_data_plane_cluster_name = "${local.outbound_vpc_resource_prefix}-data-plane"
  # If bucket_name is not provided, use the standard template for the artifact bucket. Otherwise, use the provided bucket_name value.
  artifact_bucket_name             = var.bucket_name == "" ? "sfdc-cni-artifacts-${var.env_name}-${var.region}" : var.bucket_name
}

module globals {
  source                            = "../modules/globals"
  region                            = var.region
  resource_prefix                   = local.resource_prefix
  tags                              = var.tags
  admin_role_arn                    = local.admin_role_arn
  flow_logs_retention_in_days       = var.flow_logs_retention_in_days
  bucket_name                       = local.artifact_bucket_name
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
  source                               = "../modules/traffic_vpc"
  region                               = var.region
  resource_prefix                      = local.inbound_vpc_resource_prefix
  tags                                 = var.tags
  vpc_cidr                             = var.inbound_vpc_cidr
  private_subnet_cidrs                 = var.inbound_vpc_private_subnet_cidrs
  public_subnet_cidrs                  = var.inbound_vpc_public_subnet_cidrs
  sfdc_cidr_blocks                     = var.sfdc_vpn_cidrs
  az_count                             = var.az_count
  az_names                             = local.az_names
  enable_nat_gateway                   = var.enable_inbound_nat_gateway
  enable_private_nat_routes            = var.enable_inbound_private_nat_routes
  zone_name                            = local.inbound_hosted_zone_name
  admin_role_arn                       = local.admin_role_arn
  flow_log_iam_role_arn                = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days           = var.flow_logs_retention_in_days
  data_plane_cluster_name              = local.inbound_data_plane_cluster_name
  data_plane_cluster_role_arn          = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name         = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn             = module.globals.data_plane_node_role_arn
  data_plane_node_role_name            = module.globals.data_plane_node_role_name
  transit_gateway_id                   = module.transit_gateway.tgw_id
  bastion_autoscaling_group_role_arn   = module.globals.bastion_autoscaling_group_role_arn
  bastion_instance_profile_arn         = module.globals.bastion_instance_profile_arn
  bastion_image_id                     = data.aws_ami.bastion_image_id.id
  bastion_key_name                     = module.bastion_key_pair.key_name
  node_group_key_name                  = module.node_group_key_pair.key_name
  data_plane_node_group_instance_types = var.inbound_data_plane_node_group_instance_types
  data_plane_node_group_desired_size   = var.inbound_data_plane_node_group_desired_size
  data_plane_node_group_max_size       = var.inbound_data_plane_node_group_max_size
  data_plane_node_group_min_size       = var.inbound_data_plane_node_group_min_size
  endpoint_ingress_port_from           = 443
  endpoint_ingress_port_to             = 443
}

module outbound_vpc {
  source                               = "../modules/traffic_vpc"
  region                               = var.region
  resource_prefix                      = local.outbound_vpc_resource_prefix
  tags                                 = var.tags
  vpc_cidr                             = var.outbound_vpc_cidr
  private_subnet_cidrs                 = var.outbound_vpc_private_subnet_cidrs
  public_subnet_cidrs                  = var.outbound_vpc_public_subnet_cidrs
  sfdc_cidr_blocks                     = var.sfdc_vpn_cidrs
  az_count                             = var.az_count
  az_names                             = local.az_names
  enable_nat_gateway                   = var.enable_outbound_nat_gateway
  enable_private_nat_routes            = var.enable_outbound_private_nat_routes
  zone_name                            = local.outbound_hosted_zone_name
  admin_role_arn                       = local.admin_role_arn
  flow_log_iam_role_arn                = module.globals.iam_role_flow_logs_arn
  flow_log_retention_in_days           = var.flow_logs_retention_in_days
  data_plane_cluster_name              = local.outbound_data_plane_cluster_name
  data_plane_cluster_role_arn          = module.globals.data_plane_cluster_role_arn
  data_plane_cluster_role_name         = module.globals.data_plane_cluster_role_name
  data_plane_node_role_arn             = module.globals.data_plane_node_role_arn
  data_plane_node_role_name            = module.globals.data_plane_node_role_name
  transit_gateway_id                   = module.transit_gateway.tgw_id
  bastion_autoscaling_group_role_arn   = module.globals.bastion_autoscaling_group_role_arn
  bastion_instance_profile_arn         = module.globals.bastion_instance_profile_arn
  bastion_image_id                     = data.aws_ami.bastion_image_id.id
  bastion_key_name                     = module.bastion_key_pair.key_name
  node_group_key_name                  = module.node_group_key_pair.key_name
  data_plane_node_group_instance_types = var.outbound_data_plane_node_group_instance_types
  data_plane_node_group_desired_size   = var.outbound_data_plane_node_group_desired_size
  data_plane_node_group_max_size       = var.outbound_data_plane_node_group_max_size
  data_plane_node_group_min_size       = var.outbound_data_plane_node_group_min_size
  endpoint_ingress_port_from           = 0
  endpoint_ingress_port_to             = 65535
}
