variable "cost_center" {
  default = "1410"
  type    = string
}

variable "db_allocated_storage" {
  default = 20
  type    = number
}

variable "db_backup_retention_days" {
  default = 7
  type    = number
}

variable "db_backup_window" {
  default = "00:00-00:30"
  type    = string
}

variable "db_engine" {
  default = "mysql"
  type    = string
}

variable "db_engine_version" {
  default = "5.7"
  type    = string
}

variable "db_instance_class" {
  default = "db.t3.micro"
  type    = string
}

variable "db_maintenance_window" {
  default = "Sun:00:31-Sun:01:01"
  type    = string
}

variable "environment" {
  default = "stage"
  type    = string
}

variable "memcache_node_type" {
  default = "cache.t3.micro"
  type    = string
}

variable "project" {
  default = "securitywiki"
  type    = string
}

variable "project_desc" {
  default = "securitywiki.allizom.org"
  type    = string
}

variable "project_email" {
  default = "it-sre@mozilla.com"
  type    = string
}

variable "region" {
  default = "us-west-2"
  type    = string
}
