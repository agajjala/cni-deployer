###############################
#  CNI Test State
###############################

data terraform_remote_state cni_infra {
  backend = "s3"
  config = {
    bucket         = "sfdc-cni-tf-state-${var.env_name}-${var.region}"
    dynamodb_table = "tf-state-lock"
    region         = var.region
    key            = "${var.deployment_id}/cni_test"
  }
}

###############################
#  Inbound EKS Cluster
###############################

data aws_eks_cluster inbound {
  name = data.terraform_remote_state.cni_infra.outputs.inbound_data_plane_cluster_name
}

data aws_eks_cluster_auth inbound {
  name = data.terraform_remote_state.cni_infra.outputs.inbound_data_plane_cluster_name
}

data kubernetes_service inbound {
  provider = kubernetes.inbound
  metadata {
    name = var.inbound_service_name
  }
}

# Source: https://github.com/kubernetes/kubernetes/issues/29789
data aws_lb inbound {
  name = element(split("-", element(split(".", data.kubernetes_service.inbound.load_balancer_ingress.0.hostname), 0)), 0)
}

###############################
#  Outbound EKS Cluster
###############################

data aws_eks_cluster outbound {
  name = data.terraform_remote_state.cni_infra.outputs.outbound_data_plane_cluster_name
}

data aws_eks_cluster_auth outbound {
  name = data.terraform_remote_state.cni_infra.outputs.outbound_data_plane_cluster_name
}

data kubernetes_service outbound {
  provider = kubernetes.outbound
  metadata {
    name = var.outbound_service_name
  }
}

# Source: https://github.com/kubernetes/kubernetes/issues/29789
data aws_lb outbound {
  name = element(split("-", element(split(".", data.kubernetes_service.outbound.load_balancer_ingress.0.hostname), 0)), 0)
}
