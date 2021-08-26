module "password" {
  source         = "github.com/mozilla-it/terraform-modules//aws/rand-password?ref=master"
  environment    = local.environment
  service_name   = local.project
  password_store = "secretsmanager"
  keyname        = "postgres_password"
  password_config = {
      special        = false
  }
}

resource "aws_db_instance" "careers" {
  identifier                  = "careers-${local.environment}"
  storage_type                = "gp2"
  engine                      = "postgres"
  engine_version              = local.psql_version
  instance_class              = local.psql_instance
  allocated_storage           = local.psql_storage_allocated
  max_allocated_storage       = local.psql_storage_max
  multi_az                    = local.psql_multiaz
  allow_major_version_upgrade = true
  name                        = "careers"
  username                    = "careers"
  backup_retention_period     = 15
  db_subnet_group_name        = aws_db_subnet_group.careers-db.id
  vpc_security_group_ids      = [aws_security_group.careers-db.id]
  password                    = module.password.password
}

resource "aws_db_subnet_group" "careers-db" {
  name        = "careers-${local.environment}-db"
  description = "Subnet Group for careers ${local.environment} DB"
  subnet_ids  = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
}

resource "aws_security_group" "careers-db" {
  name   = "careers-${local.environment}-db"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "TCP"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "rds_endpoint" {
  value = aws_db_instance.careers.endpoint
}
