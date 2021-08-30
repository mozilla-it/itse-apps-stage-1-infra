# Etherpad Application Secrets Metadata

resource "aws_secretsmanager_secret" "envvar" {
  name        = "/${var.environment}/etherpad/envvar"
  description = "etherpad ${var.environment} environment variables as json (see helm chart for expected json)"
}

resource "aws_secretsmanager_secret" "oidc-gateway-secrets" {
  name        = "/${var.environment}/etherpad/oidc-gateway-secrets"
  description = "etherpad ${var.environment} oidc-gateway json configuration (see oidc-gateway helm chart for expected json)"
}
