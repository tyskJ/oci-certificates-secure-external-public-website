/************************************************************
Certificate Authority
************************************************************/
resource "oci_certificates_management_certificate_authority" "root_ca" {
  compartment_id = oci_identity_compartment.workload.id
  name           = "private-root-ca"
  description    = "Private Root CA"
  kms_key_id     = oci_kms_key.key_rsa.id
  certificate_authority_config {
    config_type = "ROOT_CA_GENERATED_INTERNALLY"
    subject {
      common_name            = "SSL External Public Website"
      country                = "JP"
      state_or_province_name = "Tokyo"
      # distinguished_name_qualifier = null
      # domain_component             = null
      # generation_qualifier         = null
      # given_name                   = null
      # initials                     = null
      # locality_name                = null
      # organization                 = null
      # organizational_unit          = null
      # pseudonym                    = null
      # serial_number                = null
      # street                       = null
      # surname                      = null
      # title                        = null
      # user_id                      = null
    }
    signing_algorithm = "SHA384_WITH_RSA"
    # validity を指定すると「400-InvalidParameter」となる
    # 指定しなければ、有効期限開始は作成時刻から、有効期限終了日はMAXになるのでOK
    # validity {
    #   # 有効期限開始日＋１日～2037年12月31日の範囲で指定可能
    #   time_of_validity_not_after = "2037-12-31T23:59:59Z"
    #   # 有効期限開始日を省略すると作成時刻から有効化される
    #   time_of_validity_not_before = null
    # }
  }
  # certificate_authority_rules {
  #   rule_type = "CERTIFICATE_AUTHORITY_ISSUANCE_EXPIRY_RULE"
  #   # 認証局から発行する証明書の最大有効期限
  #   certificate_authority_max_validity_duration = "P90D"
  #   # 下位認証局の最大有効期限
  #   leaf_certificate_max_validity_duration      = "P3650D"
  # }
  # certificate_revocation_list_details {
  #   object_storage_config {
  #     object_storage_bucket_name        = ""
  #     object_storage_object_name_format = "versionName{}.crl"
  #     object_storage_namespace = ""
  #   }
  #   custom_formatted_urls = []
  # }
  defined_tags = local.common_defined_tags
}