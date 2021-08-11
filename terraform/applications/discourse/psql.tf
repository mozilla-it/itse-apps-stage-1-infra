resource "aws_db_instance" "discourse" {
  identifier                  = "discourse-${local.workspace.environment}"
  storage_type                = "gp2"
  engine                      = "postgres"
  engine_version              = local.workspace.psql_version
  instance_class              = local.workspace.psql_instance
  allocated_storage           = local.workspace.psql_storage_allocated
  max_allocated_storage       = local.workspace.psql_storage_max
  multi_az                    = local.workspace.environment == "prod" ? true : false
  allow_major_version_upgrade = true
  name                        = "discourse"
  username                    = "discourse"
  backup_retention_period     = 15
  db_subnet_group_name        = aws_db_subnet_group.discourse-db.id
  vpc_security_group_ids      = [aws_security_group.discourse-db.id]
}

resource "aws_db_subnet_group" "discourse-db" {
  name        = "discourse-${local.workspace.environment}-db"
  description = "Subnet for discourse ${local.workspace.environment} DB"
  subnet_ids  = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
}

resource "aws_security_group" "discourse-db" {
  name   = "discourse-${local.workspace.environment}-db"
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

locals {
  subnet_db_name_tags = {
    Name = "discourse-${local.workspace.environment}-redis"
  }
}

output "rds_endpoint" {
  value = aws_db_instance.discourse.endpoint
}
