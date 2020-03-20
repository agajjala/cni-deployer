resource aws_instance instance {
    ami                     = var.image_id
    instance_type           = var.instance_type
    # VPC
    subnet_id               = var.subnet_id
    # Security Group
    vpc_security_group_ids  = var.vpc_security_group_ids
    # the Public SSH key
    key_name                = var.ec2_key_name
    tags                    = var.tags
}

resource aws_eip ip {
    vpc      = true
    instance = aws_instance.instance.id
}
