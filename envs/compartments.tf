/************************************************************
Compartment - workload
************************************************************/
resource "oci_identity_compartment" "workload" {
  compartment_id = var.tenancy_ocid
  name           = "oci-certificates-secure-external-public-website"
  description    = "For OCI Certificates Secure External Public Website"
  enable_delete  = true
}