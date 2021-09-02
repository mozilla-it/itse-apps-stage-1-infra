output "cluster_id" {
  value = module.itse-apps-stage-1.cluster_id
}

output "cluster_name" {
  value = module.itse-apps-stage-1.cluster_id
}

output "cluster_worker_iam_role_arn" {
  value = module.itse-apps-stage-1.worker_iam_role_arn
}

output "cluster_oidc_issuer_url" {
  value = module.itse-apps-stage-1.cluster_oidc_issuer_url
}

output "cluster_security_group_id" {
  value = module.itse-apps-stage-1.cluster_security_group_id
}

output "worker_security_group_id" {
  value = module.itse-apps-stage-1.worker_security_group_id
}

output "refractr_eip_allocation_id" {
  value = aws_eip.refractr_eip.*.id
}

output "refractr_ips" {
  value = aws_eip.refractr_eip.*.public_ip
}
