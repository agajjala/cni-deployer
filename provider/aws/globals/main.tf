module "iam" {
  source        = "./iam"
  deployment_id = var.deployment_id
  tags          = var.tags
}

module tgw {
  source = "../modules/tgw"
  tags   = var.tags
}
