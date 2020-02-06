locals {
  vpc_type                = "outbound"
  data_plane_cluster_name = "${var.resource_prefix}-outbound-data-plane"
}

module vpc {
  source                 = "../vpc"
  tags                   = var.tags
  vpc_name               = "${var.resource_prefix}-${local.vpc_type}"
  vpc_cidr               = var.vpc_cidr
  additional_vpc_tags    = {"kubernetes.io/cluster/${local.data_plane_cluster_name}": "shared"}
  additional_subnet_tags = {"kubernetes.io/cluster/${local.data_plane_cluster_name}": "shared"}
  az_names               = var.az_names
  enable_nat_gateway     = var.enable_nat_gateway
}

module security_groups {
  source           = "../security_groups"
  resource_prefix  = var.resource_prefix
  tags             = var.tags
  vpc_id           = module.vpc.vpc_id
  vpc_type         = local.vpc_type
  sfdc_cidr_blocks = var.sfdc_cidr_blocks
}

module route53_zone {
  source    = "../route53_zone"
  tags      = var.tags
  vpc_id    = module.vpc.vpc_id
  zone_name = var.zone_name
}

module vpc_flow_log {
  source                         = "../vpc_flow_log"
  resource_prefix                = var.resource_prefix
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  vpc_type                       = local.vpc_type
  admin_role_arn                 = var.admin_role_arn
  flow_logs_iam_role_arn         = var.flow_log_iam_role_arn
  retention_in_days              = var.flow_log_retention_in_days
}

module data_plane {
  source                       = "../data_plane"
  resource_prefix              = var.resource_prefix
  tags                         = var.tags
  cluster_name                 = local.data_plane_cluster_name
  data_plane_cluster_role_arn  = var.data_plane_cluster_role_arn
  data_plane_cluster_role_name = var.data_plane_cluster_role_name
  data_plane_node_role_arn     = var.data_plane_node_role_arn
  data_plane_node_role_name    = var.data_plane_node_role_name
  admin_role_arn               = var.admin_role_arn
  retention_in_days            = var.flow_log_retention_in_days
  subnet_ids                   = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  public_access_cidrs          = var.sfdc_cidr_blocks
  scaling_config               = var.scaling_config
  security_group_ids           = [
    module.security_groups.data_plane_cluster_sg_id
  ]
  bastion_sg_id                = module.security_groups.bastion_sg_id
}

module tgw_attachment {
  source             = "../tgw_attachment"
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = var.transit_gateway_id
  private_subnet_ids = module.vpc.private_subnet_ids
}

//module "route53_resolvers" {
//  source                         = "../modules/route53_resolvers"
//  deployment_id                  = var.deployment_id
//  tags                           = var.tags
//  vpc_id                         = module.vpc.vpc_id
//  vpc_type                       = local.vpc_type
//  security_group_ids             = [module.security_groups.nginx_sg_id]
//  private_subnet_ids             = module.subnets.private_subnet_ids
//  sitebridge_control_plane_ips   = var.sitebridge_control_plane_ips
//  forwarded_domains              = var.forwarded_domains
//}

//module "sitebridge" {
//  source                         = "../modules/sitebridge"
//  deployment_id                  = var.deployment_id
//  tags                           = var.tags
//  vpc_id                         = module.vpc.vpc_id
//  private_subnet_ids             = module.subnets.private_subnet_ids
//  route_table_id                 = module.route_tables.private_route_table_id
//  bgp_asn                        = var.sitebridge_bgp_asn
//  gateway_ips                    = var.sitebridge_gateway_ips
//  data_plane_ips                 = var.sitebridge_data_plane_ips
//  control_plane_ips              = var.sitebridge_control_plane_ips
//  transit_gateway_id             = var.transit_gateway_id
//  sitebridge_security_group_id   = module.security_groups.sitebridge_sg_id
//}
