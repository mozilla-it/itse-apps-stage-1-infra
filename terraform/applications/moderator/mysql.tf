resource "aws_db_subnet_group" "moderator-db" {
  name        = "${var.project}-${var.environment}-db"
  description = "Subnet for moderator ${var.environment} DB"
  subnet_ids  = flatten([data.terraform_remote_state.vpc.outputs.private_subnets])
}

resource "aws_security_group" "moderator-db" {
  name   = "${var.project}-${var.environment}-db"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_instance" "moderator" {
  identifier                  = "${var.project}-${var.environment}"
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = var.mysql_version
  instance_class              = var.mysql_instance
  allocated_storage           = var.mysql_storage_allocated
  max_allocated_storage       = var.mysql_storage_max
  multi_az                    = var.environment == "prod" ? true : false
  allow_major_version_upgrade = true
  name                        = var.project
  username                    = var.project
  backup_retention_period     = 30
  db_subnet_group_name        = aws_db_subnet_group.moderator-db.id
  vpc_security_group_ids      = [aws_security_group.moderator-db.id]
  apply_immediately           = true
}
