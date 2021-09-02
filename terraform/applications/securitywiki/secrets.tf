# Security Wiki Application Secrets Metadata

resource "aws_secretsmanager_secret" "envvar" {
  name        = "/${var.environment}/securitywiki/envvar"
  description = "security wiki ${var.environment} environment variables as json (see helm chart for expected json)"
}
