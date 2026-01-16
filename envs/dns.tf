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

/************************************************************
Record - A
************************************************************/
resource "oci_dns_rrset" "rrset_a" {
  zone_name_or_id = oci_dns_zone.public_zone.name
  domain          = "www.${oci_dns_zone.public_zone.name}"
  rtype           = "A"
  items {
    domain = "www.${oci_dns_zone.public_zone.name}"
    rdata  = oci_load_balancer_load_balancer.flb.ip_address_details[0].ip_address
    rtype  = "A"
    ttl    = 60
  }
}