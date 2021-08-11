# discourse.dev|stage.mozit.cloud
# -> lb, k8s via external-dns

# discourse{-dev}.allizom.org
# -> email / SES setup via terraform
# -> lb, k8s via external-dns

module "discourse_mozilla" {
  source = "github.com/mozilla-it/terraform-modules//aws/dns/apex?ref=master"
  domain = local.workspace.discourse_mozilla
}
