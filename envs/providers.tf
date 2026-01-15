terraform {
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = "~> 7.29.0"
    }
  }
}

provider "oci" {
  auth                = "SecurityToken"
  config_file_profile = "ADMIN"
  region              = "ap-tokyo-1"
  ignore_defined_tags = [
    "Oracle-Tags.CreatedBy",
    "Oracle-Tags.CreatedOn",
    "Common.System"
  ]
}

provider "oci" {
  alias               = "with_system_tag"
  auth                = "SecurityToken"
  config_file_profile = "ADMIN"
  region              = "ap-tokyo-1"
  ignore_defined_tags = [
    "Oracle-Tags.CreatedBy",
    "Oracle-Tags.CreatedOn"
  ]
}