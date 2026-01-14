/************************************************************
Vault
************************************************************/
resource "oci_kms_vault" "default" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "default-vault-for-certificates"
  vault_type     = "DEFAULT"
  defined_tags   = local.common_defined_tags
}