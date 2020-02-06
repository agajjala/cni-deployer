output bastion_sg_id {
  value = aws_security_group.bastion.id
}

output nginx_sg_id {
  value = aws_security_group.nginx.id
}

output sitebridge_sg_id {
  value = aws_security_group.sitebridge.id
}

output data_plane_cluster_sg_id {
  value = aws_security_group.data_plane_cluster.id
}
