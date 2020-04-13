variable resource_prefix {
  description = "Prefix used for assigning unique naames to resources"
}
variable tags {
  description = "Map of tags used to annotate each resource supporting tags"
  type        = map(string)
  default     = {}
}
variable admin_role_arns {
  description = "List of IAM role ARNs with AWS admin privileges on created resources"
  type = list(string)
}
variable autoscaling_group_arn {
  description = "ARN of the service-linked IAM role used for autoscaling"
}
variable subnet_ids {
  description = "List of IDs corresponding to the subnets where a bastion host should be placed"
  type        = list(string)
}
variable use_latest_launch_template_version {
  description = "If true, uses the latest version of the launch template. Otherwise, uses the default version."
  type        = bool
  default     = true
}
variable image_id {
  description = "AMI from which to launch the instance"
}
variable instance_type {
  description = "Type of the instance"
  default     = "t2.micro"
}
variable key_name {
  description = "Name of the EC2 key pair used for ssh access to a bastion host"
}
variable instance_profile_arn {
  description = "ARN of the instance profile to use for bastion"
}
variable security_group_ids {
  description = "List of security groups to attach to each bastion"
  type        = list(string)
}
variable block_device_name {
  description = "Name of the block device on each bastion"
  default     = "/dev/sda1"
}
variable ebs_volume_size {
  description = "Size of the EBS volume to attach in gigabytes"
  type        = number
  default     = 20
}
