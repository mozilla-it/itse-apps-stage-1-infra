# Discourse Application Secrets Metadata

resource "aws_secretsmanager_secret" "envvar" {
  name        = "/${local.workspace.environment}/discourse/envvar"
  description = "discourse ${local.workspace.environment} environment variables as json (see helm chart for expected json)"
}


resource "aws_secretsmanager_secret" "logger" {
  name        = "/${local.workspace.environment}/discourse/logger"
  description = "discourse ${local.workspace.environment} papertrail logger configuration as json (see helm chart for expected json)"
}
