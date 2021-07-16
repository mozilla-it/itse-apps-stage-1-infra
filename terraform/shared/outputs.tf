output "cluster_id" {
  value = module.itse-apps-stage-1.cluster_id
}

output "cluster_name" {
  value = module.itse-apps-stage-1.cluster_id
}

output "cluster_oidc_issuer_url" {
  value = module.itse-apps-stage-1.cluster_oidc_issuer_url
}

output "refractr_eip_allocation_id" {
  value = aws_eip.refractr_eip.*.id
}

output "refractr_ips" {
  value = aws_eip.refractr_eip.*.public_ip
}

output "stage_dns_zone_id" {
  value = module.stage_dns_zone.zone_id
}
