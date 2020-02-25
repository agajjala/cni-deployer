resource aws_ec2_transit_gateway default {
  tags = merge(var.tags, {Name: var.name})
}
