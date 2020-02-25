resource aws_api_gateway_resource api_version {
  rest_api_id = var.api_id
  parent_id   = var.root_resource_id
  path_part   = "v1"
}
