resource aws_instance instance {
  ami                     = var.image_id
  instance_type           = var.instance_type
  # VPC
  subnet_id               = var.subnet_ids[count.index]
  # Security Group
  vpc_security_group_ids  = var.vpc_security_group_ids
  # the Public SSH key
  key_name                = var.key_name
  iam_instance_profile    = var.iam_instance_profile
  user_data               = <<EOF
#! /bin/bash

sudo yum -y install docker
sudo service docker start
sudo yum -y install awscli
aws configure set default.region ${var.region}
aws configure set default.output json
sudo $(aws ecr get-login --region ${var.region} --no-include-email)
sudo docker pull ${var.docker_image_id}
sudo docker run --log-driver=awslogs --log-opt awslogs-group=${module.monitoring_ec2_log.log_group_name} \
                -d -p 80:80 -e region=${var.region} -it ${var.docker_image_id} /bin/bash
EOF
  tags                    = var.tags

  count = length(var.subnet_ids)
}

resource aws_eip ip {
  vpc      = true
  instance = aws_instance.instance[count.index].id

  count = length(var.subnet_ids)
}

module shared_policy_documents {
  source = "../shared_policy_documents"
}

module monitoring_ec2_log {
  source              = "../log_group"
  admin_principals    = var.admin_principals
  kms_key_source_json = module.shared_policy_documents.kms_key_cloudwatch_access_json
  log_group_name      = "${var.resource_prefix}-ec2"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}
