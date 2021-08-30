variable "cost_center" {
  default = "1440"
  type    = string
}

variable "environment" {
  default = "stage"
  type    = string
}

variable "project" {
  default = "etherpad"
  type    = string
}

variable "project_desc" {
  default = "pad.allizom.org"
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
