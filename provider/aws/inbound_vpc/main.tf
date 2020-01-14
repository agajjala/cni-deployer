locals {
  vpc_type = "inbound"
}

module "vpc" {
  source        = "../modules/vpc"
  tags          = var.tags
  cidr_block    = var.vpc_cidr_block
}

module "subnets" {
  source                                = "../modules/subnets"
  tags                                  = var.tags
  vpc_id                                = module.vpc.vpc_id
  public_subnet_cidr_blocks             = var.public_subnet_cidr_blocks
  public_subnet_availability_zone_ids   = var.public_subnet_availability_zone_ids
  public_subnet_count                   = var.public_subnet_count
  private_subnet_cidr_blocks            = var.private_subnet_cidr_blocks
  private_subnet_availability_zone_ids  = var.private_subnet_availability_zone_ids
  private_subnet_count                  = var.private_subnet_count
}

module "route_tables" {
  source                = "../modules/route_tables"
  tags                  = var.tags
  vpc_id                = module.vpc.vpc_id
  igw_id                = module.gateway.igw_id
  ngw_id                = module.gateway.ngw_id
  public_subnet_ids     = module.subnets.public_subnet_ids
  public_subnet_count   = var.public_subnet_count
  private_subnet_ids    = module.subnets.private_subnet_ids
  private_subnet_count  = var.private_subnet_count
}

module "gateway" {
  source                = "../modules/gateway"
  tags                  = var.tags
  vpc_id                = module.vpc.vpc_id
  nat_gateway_subnet_id = element(module.subnets.public_subnet_ids, 0)
}

module "security_groups" {
  source        = "../modules/security_groups"
  deployment_id = var.deployment_id
  tags          = var.tags
  vpc_id        = module.vpc.vpc_id
  vpc_type      = local.vpc_type
  sfdc_cidr     = var.sfdc_cidr
}

module "load_balancers" {
  source            = "../modules/load_balancers"
  deployment_id     = var.deployment_id
  tags              = var.tags
  vpc_id            = module.vpc.vpc_id
  vpc_type          = local.vpc_type
  private_subnet_ids = module.subnets.private_subnet_ids
}

module "route53_zone" {
  source    = "../modules/route53_zone"
  tags      = var.tags
  vpc_id    = module.vpc.vpc_id
  zone_name = var.zone_name
}

module "security" {
  source                         = "../modules/security"
  deployment_id                  = var.deployment_id
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  vpc_type                       = local.vpc_type
  flow_logs_iam_role_arn         = data.aws_iam_role.flow_logs.arn
  flow_logs_cloudwatch_group_arn = data.aws_cloudwatch_log_group.log_group.arn
  flow_logs_retention_in_days    = var.flow_logs_retention_in_days
}

module "tgw_attachment" {
  source             = "../modules/tgw_attachment"
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = var.transit_gateway_id
  private_subnet_ids = module.subnets.private_subnet_ids
}

module "route53_resolvers" {
  source                         = "../modules/route53_resolvers"
  deployment_id                  = var.deployment_id
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  vpc_type                       = local.vpc_type
  security_group_ids             = [module.security_groups.nginx_sg_id]
  private_subnet_ids             = module.subnets.private_subnet_ids
  sitebridge_control_plane_ips   = var.sitebridge_control_plane_ips
  forwarded_domains              = var.forwarded_domains
}

module "sitebridge" {
  source                         = "../modules/sitebridge"
  deployment_id                  = var.deployment_id
  tags                           = var.tags
  vpc_id                         = module.vpc.vpc_id
  private_subnet_ids             = module.subnets.private_subnet_ids
  route_table_id                 = module.route_tables.private_route_table_id
  bgp_asn                        = var.sitebridge_bgp_asn
  gateway_ips                    = var.sitebridge_gateway_ips
  data_plane_ips                 = var.sitebridge_data_plane_ips
  control_plane_ips              = var.sitebridge_control_plane_ips
  transit_gateway_id             = var.transit_gateway_id
  sitebridge_security_group_id   = module.security_groups.sitebridge_sg_id
}
