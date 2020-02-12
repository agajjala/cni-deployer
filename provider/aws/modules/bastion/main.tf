###############################
#  KMS Key
###############################

data aws_iam_policy_document key_usage {
  statement {
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.autoscaling_group_arn
      ]
    }
    resources = [
      "*"
    ]
  }
  version = "2012-10-17"
}

data aws_iam_policy_document resource_attachment {
  source_json = data.aws_iam_policy_document.key_usage.json
  statement {
    actions = [
      "kms:CreateGrant"
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        var.autoscaling_group_arn
      ]
    }
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
    resources = [
      "*"
    ]
  }
  version = "2012-10-17"
}

module ebs_volume_key {
  source             = "../kms_key"
  tags               = var.tags
  admin_role_arn     = var.admin_role_arn
  source_json_policy = data.aws_iam_policy_document.resource_attachment.json
}

###############################
#  Autoscaling Group
###############################

resource aws_autoscaling_group bastion {
  name_prefix               = "${var.resource_prefix}-bastion"
  service_linked_role_arn   = var.autoscaling_group_arn
  vpc_zone_identifier       = var.subnet_ids
  availability_zones        = var.az_names
  max_size                  = length(var.az_names)
  min_size                  = 1
  wait_for_capacity_timeout = "0"

  launch_template {
    id      = aws_launch_template.bastion.id
    version = var.use_latest_launch_template_version ? aws_launch_template.bastion.latest_version : aws_launch_template.bastion.default_version
  }
}

###############################
#  Launch Template
###############################

resource aws_launch_template bastion {
  image_id               = var.image_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  tags                   = var.tags

  iam_instance_profile {
    arn = var.instance_profile_arn
  }

  network_interfaces {
    associate_public_ip_address = true
    delete_on_termination       = true
    device_index                = 0
    security_groups             = var.security_group_ids
  }

  monitoring {
    enabled = true
  }

  block_device_mappings {
    device_name = var.block_device_name

    ebs {
      delete_on_termination = true
      encrypted             = true
      kms_key_id            = module.ebs_volume_key.key_arn
      volume_size           = var.ebs_volume_size
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags          =  var.tags
  }

  tag_specifications {
    resource_type = "volume"
    tags          =  var.tags
  }
}
