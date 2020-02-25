# /info/inbound

output info_inbound_get_lambda {
  value = {
    invoke_arn    = module.inbound_private_link_info.invoke_arn
    function_name = module.inbound_private_link_info.function_name
  }
}

# /info/outbound

output info_outbound_get_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_info.invoke_arn
    function_name = module.outbound_private_link_info.function_name
  }
}

# /privatelinks/inbound

output privatelinks_inbound_update_lambda {
  value = {
    invoke_arn    = module.inbound_private_link_update.invoke_arn
    function_name = module.inbound_private_link_update.function_name
  }
}

output privatelinks_inbound_get_lambda {
  value = {
    invoke_arn    = module.inbound_private_link_get.invoke_arn
    function_name = module.inbound_private_link_get.function_name
  }
}

output privatelinks_inbound_get_one_lambda {
  value = {
    invoke_arn    = module.inbound_private_link_get_one.invoke_arn
    function_name = module.inbound_private_link_get_one.function_name
  }
}

output privatelinks_inbound_delete_lambda {
  value = {
    invoke_arn    = module.inbound_private_link_delete.invoke_arn
    function_name = module.inbound_private_link_delete.function_name
  }
}

# /privatelinks/outbound

output privatelinks_outbound_create_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_create.invoke_arn
    function_name = module.outbound_private_link_create.function_name
  }
}

output privatelinks_outbound_delete_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_delete.invoke_arn
    function_name = module.outbound_private_link_delete.function_name
  }
}

output privatelinks_outbound_update_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_update.invoke_arn
    function_name = module.outbound_private_link_update.function_name
  }
}

output privatelinks_outbound_get_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_get.invoke_arn
    function_name = module.outbound_private_link_get.function_name
  }
}

output privatelinks_outbound_get_one_lambda {
  value = {
    invoke_arn    = module.outbound_private_link_get_one.invoke_arn
    function_name = module.outbound_private_link_get_one.function_name
  }
}