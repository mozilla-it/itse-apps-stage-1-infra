variable "cost_center" {
  default = "1410"
  type    = string
}

variable "environment" {
  default = "stage"
  type    = string
}

variable "moderator_mozilla" {
  default = "moderator.allizom.org"
  type    = string
}

variable "mysql_instance" {
  default = "db.t3.micro"
  type    = string
}

variable "mysql_storage_allocated" {
  default = 5
  type    = number
}

variable "mysql_storage_max" {
  default = 20
  type    = number
}

variable "mysql_version" {
  default = "5.6"
  type    = string
}

variable "project" {
  default = "moderator"
  type    = string
}

variable "project_desc" {
  default = "moderator.allizom.org"
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
