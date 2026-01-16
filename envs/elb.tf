/************************************************************
Reserved Public IPs
************************************************************/
resource "oci_core_public_ip" "flb" {
  compartment_id = oci_identity_compartment.workload.id
  lifetime       = "RESERVED"
  display_name   = "flb-public-ip"
  defined_tags   = local.common_defined_tags
  # # IP Pool を指定しない場合は、Oracle管理のPublic IPから予約される
  # public_ip_pool_id = null
  # # Ephemeral Public IP の場合は必須
  # private_ip_id     = null
  lifecycle {
    ignore_changes = [private_ip_id]
  }
}