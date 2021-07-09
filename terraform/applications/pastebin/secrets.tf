# Pastebin Application Secrets Metadata

resource "aws_secretsmanager_secret" "envvar" {
  name        = "/${var.environment}/pastebin/envvar"
  description = "pastebin ${var.environment} environment variables as json (see helm chart for expected json)"
}
