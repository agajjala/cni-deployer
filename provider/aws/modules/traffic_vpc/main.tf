module vpc {
  source                 = "../vpc"
  tags                   = var.tags
  vpc_name               = var.resource_prefix
  vpc_cidr               = var.vpc_cidr
  additional_vpc_tags    = {"kubernetes.io/cluster/${var.data_plane_cluster_name}": "shared"}
  additional_subnet_tags = {"kubernetes.io/cluster/${var.data_plane_cluster_name}": "shared"}
  az_names               = var.az_names
  enable_nat_gateway     = var.enable_nat_gateway
}

module security_groups {
  source           = "../security_groups"
  resource_prefix  = var.resource_prefix
  tags             = var.tags
  vpc_id           = module.vpc.vpc_id
  sfdc_cidr_blocks = var.sfdc_cidr_blocks
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

module bastion {
  source                = "../bastion"
  resource_prefix       = var.resource_prefix
  tags                  = var.tags
  admin_role_arn        = var.admin_role_arn
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

module data_plane {
  source                       = "../data_plane"
  tags                         = var.tags
  cluster_name                 = var.data_plane_cluster_name
  cluster_role_arn             = var.data_plane_cluster_role_arn
  cluster_role_name            = var.data_plane_cluster_role_name
  node_group_role_arn          = var.data_plane_node_role_arn
  node_group_role_name         = var.data_plane_node_role_name
  admin_role_arn               = var.admin_role_arn
  retention_in_days            = var.flow_log_retention_in_days
  subnet_ids                   = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  public_access_cidrs          = var.sfdc_cidr_blocks
  cluster_security_group_ids   = [
    module.security_groups.data_plane_cluster_sg_id
  ]
  bastion_security_group_id    = module.security_groups.bastion_sg_id
  node_group_key_name          = var.node_group_key_name
}

resource aws_security_group_rule node_group_allow_bastion_ssh {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = module.data_plane.remote_access_security_group_id
  security_group_id        = module.security_groups.bastion_sg_id
}

module tgw_attachment {
  source             = "../tgw_attachment"
  tags               = var.tags
  vpc_id             = module.vpc.vpc_id
  transit_gateway_id = var.transit_gateway_id
  private_subnet_ids = module.vpc.private_subnet_ids
}
