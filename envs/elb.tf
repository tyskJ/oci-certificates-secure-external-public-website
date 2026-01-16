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

/************************************************************
Load Balancer
************************************************************/
resource "oci_load_balancer_load_balancer" "flb" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "flb"
  ip_mode        = "IPV4"
  is_private     = false
  reserved_ips {
    id = oci_core_public_ip.flb.id
  }
  subnet_ids = [
    oci_core_subnet.public.id
  ]
  network_security_group_ids = [
    oci_core_network_security_group.sg_flb.id
  ]
  ipv6subnet_cidr = null
  shape           = "flexible"
  shape_details {
    maximum_bandwidth_in_mbps = 20
    minimum_bandwidth_in_mbps = 10
  }
  security_attributes          = {}
  is_delete_protection_enabled = false
  is_request_id_enabled        = false
  request_id_header            = null
  defined_tags                 = local.common_defined_tags
}