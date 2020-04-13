resource aws_api_gateway_resource api_version {
  rest_api_id = var.rest_api.id
  parent_id   = var.rest_api.root_resource_id
  path_part   = "v1"
}
