module "stage_dns_zone" {
  source = "github.com/mozilla-it/terraform-modules//aws/dns/apex?ref=master"
  domain = "stage.mozit.cloud"
}
