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
  vpc_tags                  = {"kubernetes.io/cluster/${var.data_plane_cluster_name}": "shared"}
  private_subnet_tags       = {"kubernetes.io/cluster/${var.data_plane_cluster_name}": "shared", "kubernetes.io/role/internal-elb": "1"}
  public_subnet_tags        = {"kubernetes.io/cluster/${var.data_plane_cluster_name}": "shared", "kubernetes.io/role/elb": "1"}
  private_subnet_cidrs      = local.private_subnet_cidrs
  public_subnet_cidrs       = local.public_subnet_cidrs
  az_names                  = var.az_names
  enable_nat_gateway        = var.enable_nat_gateway
  enable_private_nat_routes = var.enable_private_nat_routes
}

module security_groups {
  source                     = "../security_groups"
  resource_prefix            = var.resource_prefix
  tags                       = var.tags
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr
  sfdc_cidr_blocks           = var.sfdc_cidr_blocks
  kaiju_agent_cidrs          = var.kaiju_agent_cidrs
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
  admin_role_arns         = var.admin_role_arns
  flow_logs_iam_role_arn = var.flow_log_iam_role_arn
  retention_in_days      = var.flow_log_retention_in_days
}

module bastion {
  source                = "../bastion"
  resource_prefix       = var.resource_prefix
  tags                  = var.tags
  admin_role_arns        = var.admin_role_arns
  autoscaling_group_arn = var.bastion_autoscaling_group_role_arn
  az_names              = var.az_names
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_ids    = [
    module.security_groups.bastion_sg_id
  ]
  image_id              = var.bastion_image_id
  instance_profile_arn  = var.bastion_instance_profile_arn
  key_name              = var.bastion_key_name
}

module eks_cluster {
  source                       = "../eks_cluster"
  tags                         = var.tags
  cluster_name                 = var.data_plane_cluster_name
  cluster_role_arn             = var.data_plane_cluster_role_arn
  cluster_role_name            = var.data_plane_cluster_role_name
  node_group_role_arn          = var.data_plane_node_role_arn
  node_group_role_name         = var.data_plane_node_role_name
  admin_role_arns               = var.admin_role_arns
  retention_in_days            = var.flow_log_retention_in_days
  private_subnet_ids           = module.vpc.private_subnet_ids
  public_subnet_ids            = module.vpc.public_subnet_ids
  public_access_cidrs          = var.sfdc_cidr_blocks
  cluster_security_group_ids   = [
    module.security_groups.data_plane_cluster_sg_id
  ]
  node_group_instance_types    = var.data_plane_node_group_instance_types
  bastion_security_group_id    = module.security_groups.bastion_sg_id
  node_group_key_name          = var.node_group_key_name
  node_group_desired_size      = var.data_plane_node_group_desired_size
  node_group_max_size          = var.data_plane_node_group_max_size
  node_group_min_size          = var.data_plane_node_group_min_size
}

module tgw_attachment {
  source             = "../tgw_attachment"
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = var.transit_gateway_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
