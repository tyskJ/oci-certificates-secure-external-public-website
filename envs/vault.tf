/************************************************************
Vault
************************************************************/
resource "oci_kms_vault" "default" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "default-vault-for-certificates"
  vault_type     = "DEFAULT"
  defined_tags   = local.common_defined_tags
}

/************************************************************
KMS Key
************************************************************/
resource "oci_kms_key" "key_rsa" {
  compartment_id      = oci_identity_compartment.workload.id
  display_name        = "certificates-hsm-key"
  desired_state       = "ENABLED"
  # OCI Certificates 認証局用キーの保護モードは HSMのみ対応
  # Software は不可
  protection_mode     = "HSM"
  management_endpoint = oci_kms_vault.default.management_endpoint
  key_shape {
    # OCI Certificates 認証局用キーのアルゴリズムは非対称キーのみ対応
    # AES は不可。RSA / ECDSA 可。
    algorithm = "RSA"
    length    = 512
  }
  is_auto_rotation_enabled = false
  defined_tags             = local.common_defined_tags
}