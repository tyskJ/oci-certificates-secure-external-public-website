/************************************************************
Public Zone
************************************************************/
resource "oci_dns_zone" "public_zone" {
  compartment_id = oci_identity_compartment.workload.id
  name           = var.zone_name
  zone_type      = "PRIMARY"
  scope          = "GLOBAL"
  dnssec_state   = "DISABLED"
  defined_tags   = local.common_defined_tags
}