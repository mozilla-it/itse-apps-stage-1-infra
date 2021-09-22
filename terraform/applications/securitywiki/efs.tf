resource "aws_efs_file_system" "securitywiki" {
  performance_mode = "generalPurpose"
}

resource "aws_efs_mount_target" "securitywiki" {
  count          = length(flatten([data.terraform_remote_state.vpc.outputs.private_subnets]))
  file_system_id = aws_efs_file_system.securitywiki.id
  subnet_id      = tolist(flatten([data.terraform_remote_state.vpc.outputs.private_subnets]))[count.index]
  security_groups = [
    data.terraform_remote_state.k8s.outputs.cluster_primary_security_group_id
  ]
}
