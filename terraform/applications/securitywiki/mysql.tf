resource "random_password" "securitywiki_db" {
  length  = 16
  special = false
}

resource "aws_db_subnet_group" "securitywiki_db" {
  name        = "${var.project}-${var.environment}-rds-subnet-group"
  description = "${var.project}-${var.environment}-rds-subnet-group"
  subnet_ids  = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
}

resource "aws_db_parameter_group" "securitywiki_db" {
  name   = "${var.project}-${var.environment}-pg"
  family = "${var.db_engine}${var.db_engine_version}"

  parameter {
    name         = "max_allowed_packet"
    value        = "1073741824"
    apply_method = "immediate"
  }

  parameter {
    name         = "slow_query_log"
    value        = "1"
    apply_method = "immediate"
  }
}

resource "aws_db_instance" "securitywiki" {
  identifier             = "${var.project}-${var.environment}"
  engine                 = var.db_engine
  engine_version         = var.db_engine_version
  instance_class         = var.db_instance_class
  allocated_storage      = var.db_allocated_storage
  storage_type           = "gp2"
  storage_encrypted      = true
  name                   = var.project
  username               = var.project
  password               = random_password.securitywiki_db.result
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.securitywiki_db.id
  parameter_group_name   = aws_db_parameter_group.securitywiki_db.name
  vpc_security_group_ids = [aws_security_group.securitywiki_db.id]
  publicly_accessible    = false
  skip_final_snapshot    = true
  apply_immediately      = true

  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = true
  backup_retention_period     = var.db_backup_retention_days
  backup_window               = var.db_backup_window
  maintenance_window          = var.db_maintenance_window
}

resource "aws_security_group" "securitywiki_db" {
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Allow inbound traffic into DB"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    to_port     = "3306"
    from_port   = "3306"
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
