data terraform_remote_state region_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/region_base"
    region = var.region
  }
}

data terraform_remote_state stack_base {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/stack_base"
    region = var.region
  }
}

data terraform_remote_state inbound_data_plane {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/inbound_data_plane"
    region = var.region
  }
}

data terraform_remote_state outbound_data_plane {
  backend = "s3"
  config = {
    bucket = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    key    = "${var.deployment_id}/outbound_data_plane_${var.vpc_suffix}"
    region = var.region
  }
}

###############################
#  API Key
###############################

data aws_secretsmanager_secret_version api_key {
  secret_id = "${local.resource_prefix}-api-key"
}

###############################
#  Inbound EKS Cluster
###############################

data aws_eks_cluster_auth inbound {
  name = data.terraform_remote_state.inbound_data_plane.outputs.cluster.name
}

data kubernetes_service inbound {
  provider = kubernetes.inbound
  metadata {
    name      = "${var.deployment_id}-cni-inbound"
    namespace = "cni-inbound"
  }
}

# Source: https://github.com/kubernetes/kubernetes/issues/29789
data aws_lb inbound {
  name = element(split("-", element(split(".", data.kubernetes_service.inbound.load_balancer_ingress.0.hostname), 0)), 0)
}

###############################
#  Outbound EKS Cluster
###############################

data aws_eks_cluster_auth outbound {
  name = data.terraform_remote_state.outbound_data_plane.outputs.cluster.name
}

data kubernetes_service outbound {
  provider = kubernetes.outbound
  metadata {
    name      = "${var.deployment_id}-cni-outbound"
    namespace = "cni-outbound"
  }
}

# Source: https://github.com/kubernetes/kubernetes/issues/29789
data aws_lb outbound {
  name = element(split("-", element(split(".", data.kubernetes_service.outbound.load_balancer_ingress.0.hostname), 0)), 0)
}
