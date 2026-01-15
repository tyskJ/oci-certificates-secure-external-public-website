/************************************************************
Certificate Authority
************************************************************/
resource "oci_certificates_management_certificate_authority" "root_ca" {
  compartment_id = oci_identity_compartment.workload.id
  name           = "root-ca"
  description    = "Private Root CA"
  kms_key_id     = oci_kms_key.key_rsa.id
  defined_tags   = local.common_defined_tags
  certificate_authority_config {
    config_type = "ROOT_CA_GENERATED_INTERNALLY"
    subject {
      common_name            = "SSL External Public Website"
      country                = "Japan"
      state_or_province_name = "Tokyo"
    }
  }
}