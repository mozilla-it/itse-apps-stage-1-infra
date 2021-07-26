# moderator.stage.mozit.cloud
# -> lb, k8s via external-dns

# moderator.allizom.org
# -> email / SES setup via terraform
# -> lb, k8s via external-dns

module "moderator_mozilla" {
  source = "github.com/mozilla-it/terraform-modules//aws/dns/apex?ref=master"
  domain = var.moderator_mozilla
}
