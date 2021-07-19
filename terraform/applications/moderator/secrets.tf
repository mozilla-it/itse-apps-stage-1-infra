# Moderator Application Secrets Metadata

resource "aws_secretsmanager_secret" "envvar" {
  name        = "/${var.environment}/moderator/envvar"
  description = "moderator ${var.environment} environment variables as json (see helm chart for expected json)"
}
