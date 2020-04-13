terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

locals {
  resource_prefix = "${var.env_name}-${var.region}-${var.deployment_id}"
}

###############################
#  IAM
###############################

module iam {
  source                    = "../modules/iam"
  tags                      = var.tags
  region                    = var.region
  resource_prefix           = local.resource_prefix
  private_connect_role_name = var.private_connect_role_name
}

###############################
#  Transit Gateway
###############################

resource aws_ec2_transit_gateway default {
  tags = merge(var.tags, {Name: local.resource_prefix})
}

###############################
#  Outbound DNS Zone
###############################

module outbound_dns_zone {
  source          = "../modules/outbound_dns_zone"
  tags            = var.tags
  region          = var.region
  resource_prefix = "${local.resource_prefix}-outbound"
  zone_name       = "cni-outbound.salesforce.com"
}

###############################
#  Outbound Key Pairs
###############################

module outbound_bastion_key_pair {
  source               = "../modules/ec2_key_pair"
  tags                 = var.tags
  key_name             = "${local.resource_prefix}-bastion"
  write_local_pem_file = var.write_local_pem_files
}

module outbound_node_group_key_pair {
  source               = "../modules/ec2_key_pair"
  tags                 = var.tags
  key_name             = "${local.resource_prefix}-node-group"
  write_local_pem_file = var.write_local_pem_files
}
