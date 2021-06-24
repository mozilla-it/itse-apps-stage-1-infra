# Pastebin Application Secrets Metadata

resource "aws_secretsmanager_secret" "db_host" {
  name        = "websre/pastebin/env/database_host"
  description = "pastebin stage DB_HOST"
}

resource "aws_secretsmanager_secret" "db_name" {
  name        = "websre/pastebin/env/database_name"
  description = "pastebin stage DB_NAME"
}

resource "aws_secretsmanager_secret" "db_pass" {
  name        = "websre/pastebin/env/database_password"
  description = "pastebin stage DB_PASS"
}

resource "aws_secretsmanager_secret" "db_port" {
  name        = "websre/pastebin/env/database_port"
  description = "pastebin stage DB_PORT"
}

resource "aws_secretsmanager_secret" "db_user" {
  name        = "websre/pastebin/env/database_user"
  description = "pastebin stage DB_USER"
}

resource "aws_secretsmanager_secret" "session_key" {
  name        = "websre/pastebin/env/session_key"
  description = "pastebin stage SESSION_KEY"
}
