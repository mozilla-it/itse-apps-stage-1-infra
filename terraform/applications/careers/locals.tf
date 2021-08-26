locals {
  environment            = "stage"
  project                = "careers"
  project_desc           = "careers staging deployment"
  project_email          = "it-sre@mozilla.com"
  region                 = "us-west-2"
  psql_instance          = "db.t3.small"
  psql_storage_allocated = 30
  psql_storage_max       = 100
  psql_version           = "10.15"
  psql_multiaz           = false
}
