package tflint

import rego.v1


datasets := terraform.resources("google_bigquery_dataset", {"access": {"special_group": "string"}, "location": "string"}, {"expand_mode": "none"})

deny_invalid_dataset_region contains issue if {
  location := datasets[_].config.location
  not equal(location.value, "US")

  issue := tflint.issue(`expected location to be "US"`, location.range)
}

is_not_access_configured(config) if {
  not "access" in object.keys(config)
}

bigquery_dataset contains access if {
  access := datasets[_].config.access[_]
}

deny_no_access contains issue if {
  dataset := datasets[_]
  is_not_access_configured(dataset.config)

  issue := tflint.issue(`need to explicitly define access`, dataset.decl_range)
}

deny_invalid_dataset_group contains issue if {
  equal(bigquery_dataset[i].config.special_group.value, "projectReaders")

  issue := tflint.issue(`use of special group is not allowed, use explicit GCPv2 workgroups instead`, bigquery_dataset[i].config.special_group.range)
}
