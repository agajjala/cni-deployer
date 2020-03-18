locals {
  /*
    A VPC requires fewer public addresses to be allocated compared to private addresses, so the last subnet CIDR in the
    prefix is used as a base CIDR for creating public subnets.
  */
  public_subnet_base_cidr = cidrsubnet(var.vpc_cidr, 2, length(var.az_names))
  private_subnet_cidrs    = length(var.private_subnet_cidrs) == 0 ? [
    for i in range(var.az_count): cidrsubnet(var.vpc_cidr, 2, i)
  ] : var.private_subnet_cidrs
  public_subnet_cidrs     = length(var.public_subnet_cidrs) == 0 ? [
    for i in range(var.az_count): cidrsubnet(local.public_subnet_base_cidr, 2, i)
  ] : var.public_subnet_cidrs
}

module vpc {
  source                    = "../vpc"
  tags                      = var.tags
  vpc_name                  = var.resource_prefix
  vpc_cidr                  = var.vpc_cidr
  private_subnet_cidrs      = local.private_subnet_cidrs
  public_subnet_cidrs       = local.public_subnet_cidrs
  az_names                  = var.az_names
  enable_nat_gateway        = var.enable_nat_gateway
  enable_private_nat_routes = var.enable_private_nat_routes
  map_public_ip_on_launch   = true
}

module security_groups {
  source                     = "../security_groups"
  resource_prefix            = var.resource_prefix
  tags                       = var.tags
  vpc_id                     = module.vpc.vpc_id
  sfdc_cidr_blocks           = var.sfdc_cidr_blocks
  endpoint_ingress_port_from = var.endpoint_ingress_port_from
  endpoint_ingress_port_to   = var.endpoint_ingress_port_to
}

module route53_zone {
  source    = "../route53_zone"
  tags      = var.tags
  vpc_id    = module.vpc.vpc_id
  zone_name = var.zone_name
}

module vpc_flow_log {
  source                 = "../vpc_flow_log"
  resource_prefix        = var.resource_prefix
  tags                   = var.tags
  vpc_id                 = module.vpc.vpc_id
  admin_role_arn         = var.admin_role_arn
  flow_logs_iam_role_arn = var.flow_log_iam_role_arn
  retention_in_days      = var.flow_log_retention_in_days
}

module ec2 {
  source                  = "../ec2"
  image_id                = var.image_id
  instance_type           = var.instance_type
  vpc_id                  = module.vpc.vpc_id
  subnet_id               = element(module.vpc.public_subnet_ids, 0)
  vpc_security_group_ids  = [module.security_groups.monitoring_ec2_sg_id]
  ec2_key_name            = var.ec2_key_name
  tags                    = var.tags
}
