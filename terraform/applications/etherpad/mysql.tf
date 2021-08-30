module "etherpad_db" {
  source = "github.com/mozilla-it/terraform-modules//aws/database?ref=master"

  cost_center          = var.cost_center
  environment          = var.environment
  identifier           = "${var.project}-${var.environment}"
  name                 = var.project
  parameter_group_name = aws_db_parameter_group.etherpad.name
  project              = var.project
  storage_gb           = 20
  subnets              = data.terraform_remote_state.vpc.outputs.private_subnets
  type                 = "mysql"
  username             = var.project
  vpc_id               = data.terraform_remote_state.vpc.outputs.vpc_id
}

resource "aws_db_parameter_group" "etherpad" {
  name   = "${var.project}-${var.environment}-mysql"
  family = "mysql5.7"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
}
