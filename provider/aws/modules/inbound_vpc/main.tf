locals {
  vpc_type = "inbound"
}

module region_metadata {
  source = "../region_metadata"
  region = var.region
}

module "vpc" {
  source        = "../vpc"
  tags          = var.tags
  cidr_block    = var.vpc_cidr
}

module "subnets" {
  source                   = "../subnets"
  tags                     = var.tags
  vpc_id                   = module.vpc.vpc_id
  subnet_az_ids            = slice(module.region_metadata.az_ids, 0, var.az_count)
  vpc_cidr                 = var.vpc_cidr
}

module "route_tables" {
  source                = "../route_tables"
  tags                  = var.tags
  vpc_id                = module.vpc.vpc_id
  igw_id                = module.gateway.igw_id
  ngw_id                = module.gateway.ngw_id
  public_subnet_ids     = module.subnets.public_subnet_ids
  private_subnet_ids    = module.subnets.private_subnet_ids
}

module "gateway" {
  source                = "../gateway"
  tags                  = var.tags
  vpc_id                = module.vpc.vpc_id
  nat_gateway_subnet_id = element(module.subnets.public_subnet_ids, 0)
}

module "security_groups" {
  source           = "../security_groups"
  resource_prefix  = var.resource_prefix
  tags             = var.tags
  vpc_id           = module.vpc.vpc_id
  vpc_type         = local.vpc_type
  sfdc_cidr_blocks = var.sfdc_cidr_blocks
}

module "load_balancers" {
  source            = "../load_balancers"
  resource_prefix   = var.resource_prefix
  tags              = var.tags
  vpc_id            = module.vpc.vpc_id
  vpc_type          = local.vpc_type
  private_subnet_ids = module.subnets.private_subnet_ids
}

module "route53_zone" {
  source    = "../route53_zone"
  tags      = var.tags
  vpc_id    = module.vpc.vpc_id
  zone_name = var.zone_name
}

module "security" {
  source                         = "../security"
  resource_prefix                = var.resource_prefix
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  vpc_type                       = local.vpc_type
  flow_logs_iam_role_arn         = var.flow_logs_iam_role_arn
  flow_logs_cloudwatch_group_arn = var.flow_logs_cloudwatch_group_arn
}

//module "tgw_attachment" {
//  source             = "../modules/tgw_attachment"
//  tags               = var.tags
//  vpc_id             = module.vpc.vpc_id
//  transit_gateway_id = var.transit_gateway_id
//  private_subnet_ids = module.subnets.private_subnet_ids
//}
//
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
//
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

//module vpc_endpoint_service {
//  source                     = "../modules/vpc_endpoint_service"
//  tags                       = var.tags
//  network_load_balancer_arns = [module.load_balancers.private_network_lb_arn]
//  vpce_connections_topic_arn = data.terraform_remote_state.globals.outputs.sns_topic_vpce_connections_arn
//}
