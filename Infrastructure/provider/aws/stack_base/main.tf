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
  source                             = "../modules/iam"
  tags                               = var.tags
  region                             = var.region
  resource_prefix                    = local.resource_prefix
  private_connect_role_name          = var.private_connect_role_name
  api_authorizer_c2c_key_secret_name = var.api_authorizer_c2c_key_secret_name
  monitoring_s3_bucket               = var.monitoring_s3_bucket
}

###############################
#  Transit Gateway
###############################

resource aws_ec2_transit_gateway default {
  tags  = merge(var.tags, { Name : local.resource_prefix })

  count = var.enable_transit_gateway ? 1 : 0
}

resource aws_ssm_parameter transit_gateway_id {
  tags        = var.tags
  name        = format("/%s-%s/%s/tgw/id", var.env_name, var.region, var.deployment_id)
  type        = "SecureString"
  value       = aws_ec2_transit_gateway.default.id

  count       = var.enable_transit_gateway ? 1 : 0
}

###############################
#  Customer Gateways
###############################

resource aws_customer_gateway default {
  tags       = merge(var.tags, { Name : "${local.resource_prefix}-${count.index}" })
  bgp_asn    = var.sitebridge_config.bgp_asn
  ip_address = trimsuffix(var.sitebridge_config.gateway_ips[count.index], "/32")
  type       = "ipsec.1"

  count = var.enable_sitebridge ? length(var.sitebridge_config.gateway_ips) : 0
}

###############################
#  VPN Connections
###############################

resource aws_vpn_connection default {
  tags                = merge(var.tags, { Name : "${local.resource_prefix}-${count.index}" })
  customer_gateway_id = aws_customer_gateway.default[count.index].id
  transit_gateway_id  = aws_ec2_transit_gateway.default[0].id
  type                = aws_customer_gateway.default[count.index].type

  count = var.enable_sitebridge ? length(var.sitebridge_config.gateway_ips) : 0
}

resource aws_ssm_parameter vpn_connections_ids {
  tags        = var.tags
  name        = format("/%s-%s/%s/vpn/ids", var.env_name, var.region, var.deployment_id)
  type        = "SecureString"
  value       = join(",", aws_vpn_connection.default.*.id)

  count       = var.enable_sitebridge ? 1 : 0
}

###############################
#  Shared DNS Zones
###############################

resource aws_vpc shared_dns_zone {
  tags                 = merge(var.tags, { Name : "${local.resource_prefix}-shared-dns-zone" })
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource aws_route53_zone outbound_dns_zone {
  tags    = var.tags
  name    = "cni-outbound.salesforce.com"
  comment = "${local.resource_prefix}-outbound-dns-zone"

  lifecycle {
    ignore_changes = [vpc]
  }

  vpc {
    vpc_id = aws_vpc.shared_dns_zone.id
  }
}

resource aws_route53_zone sitebridge_dns_zone {
  tags    = var.tags
  name    = "sfdcsb.net"
  comment = "${local.resource_prefix}-sitebridge-dns-zone"

  lifecycle {
    ignore_changes = [vpc]
  }

  vpc {
    vpc_id = aws_vpc.shared_dns_zone.id
  }
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
