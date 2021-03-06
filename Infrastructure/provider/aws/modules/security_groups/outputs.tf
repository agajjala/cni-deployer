output bastion_sg_id {
  value = aws_security_group.bastion.id
}

output nginx_sg_id {
  value = aws_security_group.nginx.id
}

output nginx {
  value = aws_security_group.nginx
}

output data_plane_cluster {
  value = aws_security_group.data_plane_cluster
}

output data_plane_cluster_sg_id {
  value = aws_security_group.data_plane_cluster.id
}

output monitoring_ec2_sg_id {
  value = aws_security_group.monitoring_ec2.id
}
