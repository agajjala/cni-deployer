terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = "${var.env_name}-${var.region}-${var.deployment_id}-outbound-${var.vpc_suffix}"
  cluster_name    = "${local.resource_prefix}-data-plane"
  az_names        = slice(sort(data.aws_availability_zones.available.names), 0, var.az_count)
  /*
    The VPC requires fewer public addresses to be allocated compared to private addresses, so the last subnet CIDR in the
    prefix is used as a base CIDR for creating public subnets.
  */
  vpc_config = var.outbound_vpcs_config[var.vpc_suffix]
  vpc_cidr  = local.vpc_config["vpc_cidr"]
  public_subnet_base_cidr = cidrsubnet(local.vpc_cidr, 2, var.az_count)
  private_subnet_cidrs = lookup(local.vpc_config,"vpc_private_subnet_cidrs", [
    for i in range(var.az_count) : cidrsubnet(local.vpc_cidr, 2, i)
  ])
  public_subnet_cidrs = lookup(local.vpc_config,"vpc_public_subnet_cidrs", [
    for i in range(var.az_count) : cidrsubnet(local.public_subnet_base_cidr, 2, i)
  ])
}

###############################
#  VPC
###############################

module vpc {
  source                    = "../modules/vpc"
  tags                      = var.tags
  vpc_name                  = local.resource_prefix
  vpc_cidr                  = local.vpc_cidr
  vpc_tags                  = { "kubernetes.io/cluster/${local.cluster_name}" : "shared" }
  private_subnet_tags       = { "kubernetes.io/cluster/${local.cluster_name}" : "shared", "kubernetes.io/role/internal-elb" : "1" }
  public_subnet_tags        = { "kubernetes.io/cluster/${local.cluster_name}" : "shared", "kubernetes.io/role/elb" : "1" }
  private_subnet_cidrs      = local.private_subnet_cidrs
  public_subnet_cidrs       = local.public_subnet_cidrs
  az_names                  = local.az_names
  enable_nat_gateway        = var.enable_outbound_nat_gateway
  enable_private_nat_routes = var.enable_outbound_private_nat_routes
}

###############################
#  Security Groups
###############################

module security_groups {
  source                     = "../modules/security_groups"
  resource_prefix            = local.resource_prefix
  tags                       = var.tags
  vpc_id                     = module.vpc.vpc_id
  vpc_cidr                   = module.vpc.vpc_cidr
  sfdc_cidr_blocks           = var.sfdc_vpn_cidrs
  kaiju_agent_cidrs          = []
  endpoint_ingress_port_from = 0
  endpoint_ingress_port_to   = 65535
}

###############################
#  VPC Flow Logs
###############################

module vpc_flow_log {
  source                 = "../modules/vpc_flow_log"
  resource_prefix        = local.resource_prefix
  tags                   = var.tags
  vpc_id                 = module.vpc.vpc_id
  admin_principals       = data.terraform_remote_state.region_base.outputs.admin_principals
  flow_logs_iam_role_arn = data.terraform_remote_state.stack_base.outputs.iam.flow_logs_role.arn
  retention_in_days      = var.flow_logs_retention_in_days
}

###############################
#  Bastion
###############################

module bastion {
  source                = "../modules/bastion"
  resource_prefix       = local.resource_prefix
  tags                  = var.tags
  admin_principals      = data.terraform_remote_state.region_base.outputs.admin_principals
  autoscaling_group_arn = data.terraform_remote_state.stack_base.outputs.iam.bastion_autoscaling_group_role.arn
  subnet_ids            = module.vpc.public_subnet_ids
  security_group_ids = [
    module.security_groups.bastion_sg_id
  ]
  image_id             = data.aws_ami.bastion_image_id.id
  instance_profile_arn = data.terraform_remote_state.stack_base.outputs.iam.bastion_instance_profile.arn
  key_name             = data.terraform_remote_state.stack_base.outputs.outbound_bastion_key_pair.key_name
}

###############################
#  EKS Cluster
###############################

module eks_cluster {
  source               = "../modules/eks_cluster"
  tags                 = var.tags
  cluster_name         = local.cluster_name
  cluster_role_arn     = data.terraform_remote_state.stack_base.outputs.iam.data_plane_cluster_role.arn
  cluster_role_name    = data.terraform_remote_state.stack_base.outputs.iam.data_plane_cluster_role.name
  node_group_role_arn  = data.terraform_remote_state.stack_base.outputs.iam.data_plane_node_group_role.arn
  node_group_role_name = data.terraform_remote_state.stack_base.outputs.iam.data_plane_node_group_role.name
  admin_principals     = data.terraform_remote_state.region_base.outputs.admin_principals
  retention_in_days    = var.flow_logs_retention_in_days
  private_subnet_ids   = module.vpc.private_subnet_ids
  public_subnet_ids    = module.vpc.public_subnet_ids
  public_access_cidrs  = var.sfdc_vpn_cidrs
  cluster_security_group_ids = [
    module.security_groups.data_plane_cluster.id,
    module.security_groups.nginx.id
  ]
  node_group_instance_types = var.outbound_data_plane_node_group_instance_types
  bastion_security_group_id = module.security_groups.bastion_sg_id
  node_group_key_name       = data.terraform_remote_state.stack_base.outputs.outbound_node_group_key_pair.key_name
  node_group_desired_size   = var.outbound_data_plane_node_group_desired_size
  node_group_max_size       = var.outbound_data_plane_node_group_max_size
  node_group_min_size       = var.outbound_data_plane_node_group_min_size
}

resource aws_ssm_parameter cluster_name {
  tags        = var.tags
  name        = format("/%s-%s/%s/outbound-data-plane/%s/cluster-name", var.env_name, var.region, var.deployment_id, var.vpc_suffix)
  type        = "SecureString"
  value       = module.eks_cluster.cluster.name
}

###############################
#  Sitebridge Routing
###############################

resource aws_ec2_transit_gateway_vpc_attachment tgw_attachment {
  transit_gateway_id = data.terraform_remote_state.stack_base.outputs.transit_gateway[0].id
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids

  count = var.enable_sitebridge ? 1 : 0
}

module sitebridge_vpc_routing {
  source                       = "../modules/sitebridge_vpc_routing"
  enable_sitebridge            = var.enable_sitebridge
  tags                         = var.tags
  resource_prefix              = local.resource_prefix
  vpc_id                       = module.vpc.vpc_id
  private_subnet_ids           = module.vpc.private_subnet_ids
  transit_gateway              = data.terraform_remote_state.stack_base.outputs.transit_gateway
  sitebridge_sg_id             = module.eks_cluster.cluster_security_group_id
  control_plane_ips            = var.sitebridge_config.control_plane_ips
  data_plane_cidrs             = var.sitebridge_config.data_plane_cidrs
  private_route_table_ids      = module.vpc.private_route_table_ids
  forwarded_domains            = var.sitebridge_config.forwarded_domains
}

###############################
#  DNS Zone Association
###############################

resource aws_route53_zone_association outbound {
  zone_id = data.terraform_remote_state.stack_base.outputs.outbound_dns_zone.id
  vpc_id  = module.vpc.vpc_id
}

resource aws_route53_zone_association sitebridge {
  zone_id = data.terraform_remote_state.stack_base.outputs.sitebridge_dns_zone.id
  vpc_id  = module.vpc.vpc_id

  count = var.enable_sitebridge ? 1 : 0
}
