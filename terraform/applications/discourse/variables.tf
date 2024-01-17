locals {

  env = {
    defaults = {
      cf_cache_compress = "true"
      cf_price_class    = "PriceClass_100"
      cost_center       = "1410"
      project           = "discourse"
      project_desc      = "discourse.mozilla.org"
      project_email     = "it-sre@mozilla.com"
      region            = "us-west-2"
      ca_cert_identifier = "rds-ca-rsa4096-g1"
      apply_immediately = false
    }

    dev = {
      discourse_cdn_zone     = "discourse-dev.itsre-apps.mozit.cloud"
      discourse_mozilla      = "discourse-dev.allizom.org"
      environment            = "dev"
      psql_instance          = "db.t3.micro"
      psql_storage_allocated = 10
      psql_storage_max       = 50
      psql_version           = "10"
      redis_instance         = "cache.t2.small"
      redis_num_nodes        = 1
      redis_version          = "5.0.4"
      ca_cert_identifier = "rds-ca-rsa4096-g1"
      apply_immediately = true


    }

    stage = {
      discourse_cdn_zone     = "discourse-stage.itsre-apps.mozit.cloud"
      discourse_mozilla      = "discourse.allizom.org"
      environment            = "stage"
      psql_instance          = "db.t3.micro"
      psql_storage_allocated = 10
      psql_storage_max       = 50
      psql_version           = "10"
      redis_instance         = "cache.t2.small"
      redis_num_nodes        = 1
      redis_version          = "5.0.4"
      ca_cert_identifier = "rds-ca-rsa4096-g1"
      apply_immediately = false
    }
  }

  workspace = merge(local.env["defaults"], local.env[terraform.workspace])
}

output "workspace" {
  value = terraform.workspace
}
