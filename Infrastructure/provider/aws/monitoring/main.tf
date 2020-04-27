terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = "${var.env_name}-${var.region}-${var.deployment_id}-monitoring"
  az_names        = slice(sort(data.aws_availability_zones.available.names), 0, var.az_count)
  zone_name       = "cni-monitoring.salesforce.com"
  /*
  The VPC requires fewer public addresses to be allocated compared to private addresses, so the last subnet CIDR in the
  prefix is used as a base CIDR for creating public subnets.
*/
  public_subnet_base_cidr = cidrsubnet(var.monitoring_vpc_cidr, 2, var.az_count)
  private_subnet_cidrs = length(var.monitoring_vpc_private_subnet_cidrs) == 0 ? [
    for i in range(var.az_count) : cidrsubnet(var.monitoring_vpc_cidr, 2, i)
  ] : var.monitoring_vpc_private_subnet_cidrs
  public_subnet_cidrs = length(var.monitoring_vpc_public_subnet_cidrs) == 0 ? [
    for i in range(var.az_count) : cidrsubnet(local.public_subnet_base_cidr, 2, i)
  ] : var.monitoring_vpc_public_subnet_cidrs
}

###############################
#  VPC
###############################

module vpc {
  source                    = "../modules/vpc"
  tags                      = var.tags
  vpc_name                  = local.resource_prefix
  vpc_cidr                  = var.monitoring_vpc_cidr
  private_subnet_cidrs      = local.private_subnet_cidrs
  public_subnet_cidrs       = local.public_subnet_cidrs
  az_names                  = local.az_names
  enable_nat_gateway        = var.enable_monitoring_nat_gateway
  enable_private_nat_routes = var.enable_monitoring_private_nat_routes
  map_public_ip_on_launch   = true
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
  kaiju_agent_cidrs          = var.kaiju_agent_cidrs
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
  admin_role_arns        = data.terraform_remote_state.region_base.outputs.admin_role_arns
  flow_logs_iam_role_arn = data.terraform_remote_state.stack_base.outputs.iam.flow_logs_role.arn
  retention_in_days      = var.flow_logs_retention_in_days
}

###############################
#  DNS Zone
###############################

resource aws_route53_zone zone {
  tags = var.tags
  name = local.zone_name

  vpc {
    vpc_id = module.vpc.vpc_id
  }
}

###############################
#  Key Pair
###############################

module monitoring_ec2_key_pair {
  tags                 = var.tags
  source               = "../modules/ec2_key_pair"
  key_name             = "${local.resource_prefix}-ec2"
  write_local_pem_file = var.write_local_pem_files
}

###############################
#  Monitoring Instance
###############################

module ec2 {
  source                 = "../modules/ec2"
  image_id               = data.aws_ami.bastion_image_id.id
  instance_type          = var.monitoring_instance_type
  vpc_id                 = module.vpc.vpc_id
  subnet_ids             = length(module.vpc.public_subnet_ids) > 0 ? [module.vpc.public_subnet_ids[0]] : []
  vpc_security_group_ids = [module.security_groups.monitoring_ec2_sg_id]
  key_name               = module.monitoring_ec2_key_pair.key.key_name
  iam_instance_profile   = data.terraform_remote_state.stack_base.outputs.iam.monitoring_ec2_instance_profile.name
  region                 = var.region
  docker_image_id        = join(":", [var.monitoring.image, var.monitoring.version])
  tags                   = var.tags
  admin_role_arns        = data.terraform_remote_state.region_base.outputs.admin_role_arns
  resource_prefix        = local.resource_prefix
  retention_in_days      = var.flow_logs_retention_in_days
}
