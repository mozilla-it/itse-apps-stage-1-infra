# moderator.stage.mozit.cloud
# -> lb, k8s

# moderator.allizom.org
# -> email / SES setup
# -> lb, k8s

module "moderator_mozit" {
  source       = "github.com/mozilla-it/terraform-modules//aws/dns/subdomain?ref=master"
  domain       = var.moderator_mozit
  apex_zone_id = data.terraform_remote_state.k8s.outputs.stage_dns_zone_id
}

module "moderator_mozilla" {
  source = "github.com/mozilla-it/terraform-modules//aws/dns/apex?ref=master"
  domain = var.moderator_mozilla
}
