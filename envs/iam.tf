/************************************************************
Dynamic Group - Certificates
************************************************************/
# Terraform で動的グループを作成するには、ルートコンパートメントのDefaultドメインにしか作成できない
# 手動で作成する分には、別のアイデンティティドメインに作成可能
# 動的グループ名はテナンシ内で一意であること
resource "oci_identity_dynamic_group" "dg_certificates" {
  provider       = oci.with_system_tag
  compartment_id = var.tenancy_ocid
  name           = "Certificates_Dynamic_Group"
  description    = "Certificates Dynamic Group"
  matching_rule = format(
    "All {resource.type ='certificateauthority', tag.%s.%s.value = '%s'}",
    oci_identity_tag_namespace.common.name,
    oci_identity_tag.key_system.name,
    oci_identity_tag_default.key_system.value
  )
  defined_tags = {
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_system.tag_definition_name)             = "${oci_identity_tag_default.key_system.value}"
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_env.tag_definition_name)                = "prd"
    format("%s.%s", oci_identity_tag_namespace.common.name, oci_identity_tag_default.key_managedbyterraform.tag_definition_name) = "true"
  }
}

/************************************************************
IAM Policy - Certificates
************************************************************/
resource "oci_identity_policy" "certificates_for_vault" {
  compartment_id = oci_identity_compartment.workload.id
  description    = "OCI Certificates Policy for Vault"
  name           = "certificates-policy"
  statements = [
    format("allow dynamic-group Default/%s to use keys in compartment %s", oci_identity_dynamic_group.dg_certificates.name, oci_identity_compartment.workload.name)
  ]
  defined_tags = local.common_defined_tags
}