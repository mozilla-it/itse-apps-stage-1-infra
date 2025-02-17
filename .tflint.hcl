plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "opa" {
  enabled = true
  version = "0.7.0"
  source  = "github.com/terraform-linters/tflint-ruleset-opa"
}

plugin "google" {
    enabled = true
    version = "0.29.0"
    source  = "github.com/terraform-linters/tflint-ruleset-google"
}

config {
  call_module_type = "local"
}

rule "terraform_required_version" {
  enabled = false
}

rule "terraform_required_providers" {
  enabled = false
}

rule "terraform_module_pinned_source" {
  enabled = false
}
