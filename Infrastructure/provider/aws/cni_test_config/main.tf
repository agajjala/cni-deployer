terraform {
  backend s3 {}
}

provider aws {
  region = var.region
}

provider kubernetes {
  alias                  = "inbound"
  version                = "1.10.0"
  host                   = data.aws_eks_cluster.inbound.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.inbound.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.inbound.token
  load_config_file       = false
}

provider kubernetes {
  alias                  = "outbound"
  version                = "1.10.0"
  host                   = data.aws_eks_cluster.outbound.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.outbound.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.outbound.token
  load_config_file       = false
}

module inbound_vpc_endpoint_service {
  source                     = "../modules/vpc_endpoint_service"
  tags                       = var.tags
  vpce_connections_topic_arn = data.terraform_remote_state.cni_infra.outputs.inbound_vpce_connections_topic_arn
  nlb_arn                    = data.aws_lb.inbound.arn
}

module inbound_private_link_config_settings {
  source                    = "../modules/inbound_private_link_config_settings"
  table_name                = data.terraform_remote_state.cni_infra.outputs.inbound_config_table_name
  table_hash_key            = data.terraform_remote_state.cni_infra.outputs.inbound_config_hash_key
  api_key                   = var.inbound_api_key
  hosted_zone_id            = data.terraform_remote_state.cni_infra.outputs.inbound_hosted_zone_id
  hosted_zone_name          = data.terraform_remote_state.cni_infra.outputs.inbound_hosted_zone_name
  vpc_endpoint_service_id   = module.inbound_vpc_endpoint_service.id
  vpc_endpoint_service_name = module.inbound_vpc_endpoint_service.service_name
}

module outbound_private_link_config_settings {
  source                         = "../modules/outbound_private_link_config_settings"
  table_name                     = data.terraform_remote_state.cni_infra.outputs.outbound_config_table_name
  table_hash_key                 = data.terraform_remote_state.cni_infra.outputs.outbound_config_hash_key
  api_key                        = var.outbound_api_key
  hosted_zone_id                 = data.terraform_remote_state.cni_infra.outputs.outbound_hosted_zone_id
  hosted_zone_name               = data.terraform_remote_state.cni_infra.outputs.outbound_hosted_zone_name
  private_link_access_role_arn   = data.terraform_remote_state.cni_infra.outputs.private_link_access_role_arn
  vpc_id                         = data.terraform_remote_state.cni_infra.outputs.outbound_vpc_id
  vpce_connections_topic_arn     = data.terraform_remote_state.cni_infra.outputs.outbound_vpce_connections_topic_arn
  private_subnet_ids             = data.terraform_remote_state.cni_infra.outputs.outbound_private_subnet_ids
  nlb_dns_name                   = data.aws_lb.outbound.dns_name
  nginx_sg_id                    = data.terraform_remote_state.cni_infra.outputs.outbound_nginx_sg_id
}
