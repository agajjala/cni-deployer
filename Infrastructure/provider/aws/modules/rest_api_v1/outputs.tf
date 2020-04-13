output resource_hash {
  value = sha1(join(",", [
    jsonencode(aws_api_gateway_authorizer.authorizer),
    jsonencode(aws_api_gateway_resource.api_version),
    jsonencode(aws_api_gateway_resource.info),
    jsonencode(aws_api_gateway_resource.info_inbound),
    jsonencode(aws_api_gateway_resource.info_outbound),
    jsonencode(aws_api_gateway_resource.privatelinks),
    jsonencode(aws_api_gateway_resource.privatelinks_inbound),
    jsonencode(aws_api_gateway_resource.privatelinks_inbound_item),
    jsonencode(aws_api_gateway_resource.privatelinks_outbound),
    jsonencode(aws_api_gateway_resource.privatelinks_outbound_item),
    module.authorizer_function.resource_hash,
    module.info_inbound_get.resource_hash,
    module.info_outbound_get.resource_hash,
    module.privatelinks_inbound_get.resource_hash,
    module.privatelinks_inbound_item_get.resource_hash,
    module.privatelinks_inbound_item_put.resource_hash,
    module.privatelinks_inbound_item_delete.resource_hash,
    module.privatelinks_inbound_item_patch.resource_hash,
    module.privatelinks_outbound_get.resource_hash,
    module.privatelinks_outbound_post.resource_hash,
    module.privatelinks_outbound_item_get.resource_hash,
    module.privatelinks_outbound_item_put.resource_hash,
    module.privatelinks_outbound_item_delete.resource_hash,
    module.privatelinks_outbound_item_patch.resource_hash
  ]))
}
