/************************************************************
VCN
************************************************************/
resource "oci_core_vcn" "vcn" {
  compartment_id = oci_identity_compartment.workload.id
  cidr_block     = "10.0.0.0/16"
  display_name   = "vcn"
  # 最大15文字の英数字
  # 文字から始めること
  # ハイフンとアンダースコアは使用不可
  # 後から変更不可
  dns_label    = "vcn"
  defined_tags = local.common_defined_tags
}

/************************************************************
Security List
************************************************************/
resource "oci_core_security_list" "sl_public" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "sl-public"
  defined_tags   = local.common_defined_tags
}

resource "oci_core_security_list" "sl_private" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "sl-private"
  defined_tags   = local.common_defined_tags
  # セッションを張る際は、Bastion Private Endpoint が送信元となる
  # Bastion Private Endpoint がターゲットリソースと同一サブネットでも、許可する必要がある点注意
  # Bastion Private Endpoint は NSG で制御できないので、SL での制御が必要
  egress_security_rules {
    protocol         = "6"
    description      = "Connect to SSH"
    destination      = "10.0.2.0/24"
    stateless        = false
    destination_type = "CIDR_BLOCK"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

/************************************************************
Subnet
************************************************************/
resource "oci_core_subnet" "public" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = "10.0.1.0/24"
  display_name   = "public"
  # 最大15文字の英数字
  # 文字から始めること
  # ハイフンとアンダースコアは使用不可
  # 後から変更不可
  dns_label         = "public"
  security_list_ids = [oci_core_security_list.sl_public.id]
  # prohibit_internet_ingress と prohibit_public_ip_on_vnic は 同様の動き
  # そのため、２つのパラメータの true/false を互い違いにするとconflictでエラーとなる
  # 基本的には、値を揃えるか、どちらか一方を明記すること
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
  defined_tags               = local.common_defined_tags
}

resource "oci_core_subnet" "private" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  cidr_block     = "10.0.2.0/24"
  display_name   = "private"
  # 最大15文字の英数字
  # 文字から始めること
  # ハイフンとアンダースコアは使用不可
  # 後から変更不可
  dns_label         = "private"
  security_list_ids = [oci_core_security_list.sl_private.id]
  # prohibit_internet_ingress と prohibit_public_ip_on_vnic は 同様の動き
  # そのため、２つのパラメータの true/false を互い違いにするとconflictでエラーとなる
  # 基本的には、値を揃えるか、どちらか一方を明記すること
  prohibit_internet_ingress  = true
  prohibit_public_ip_on_vnic = true
  defined_tags               = local.common_defined_tags
}

/************************************************************
Internet Gateway
************************************************************/
resource "oci_core_internet_gateway" "igw" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "igw"
  defined_tags   = local.common_defined_tags
}

/************************************************************
Reserved Public IPs
************************************************************/
resource "oci_core_public_ip" "ngw" {
  compartment_id = oci_identity_compartment.workload.id
  lifetime       = "RESERVED"
  display_name   = "ngw-public-ip"
  defined_tags   = local.common_defined_tags
  # # IP Pool を指定しない場合は、Oracle管理のPublic IPから予約される
  # public_ip_pool_id = null
  # # Ephemeral Public IP の場合は必須
  # private_ip_id     = null
}

/************************************************************
NAT Gateway
************************************************************/
resource "oci_core_nat_gateway" "ngw" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "ngw"
  vcn_id         = oci_core_vcn.vcn.id
  block_traffic  = false
  public_ip_id   = oci_core_public_ip.ngw.id
  defined_tags   = local.common_defined_tags
}

/************************************************************
Service Gateway
# ************************************************************/
resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "service-gateway"
  vcn_id         = oci_core_vcn.vcn.id
  services {
    # All NRT Services In Oracle Services Network
    service_id = data.oci_core_services.this.services[1].id
  }
  # route_table_id = null
  defined_tags = local.common_defined_tags
}

/************************************************************
Route Table
************************************************************/
resource "oci_core_route_table" "rtb_flb" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "rtb-flb"
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  defined_tags = local.common_defined_tags
}

resource "oci_core_route_table_attachment" "rtb_flb_attachment" {
  subnet_id      = oci_core_subnet.public.id
  route_table_id = oci_core_route_table.rtb_flb.id
}

resource "oci_core_route_table" "rtb_compute" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "rtb-compute"
  route_rules {
    network_entity_id = oci_core_nat_gateway.ngw.id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
  route_rules {
    network_entity_id = oci_core_service_gateway.service_gateway.id
    destination       = data.oci_core_services.this.services[1].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
  }
  defined_tags = local.common_defined_tags
}

resource "oci_core_route_table_attachment" "rtb_compute_attachment" {
  subnet_id      = oci_core_subnet.private.id
  route_table_id = oci_core_route_table.rtb_compute.id
}

/************************************************************
Network Security Group
************************************************************/
resource "oci_core_network_security_group" "sg_flb" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "sg-flb"
  defined_tags   = local.common_defined_tags
}

resource "oci_core_network_security_group_security_rule" "sg_flb_ingress_https" {
  network_security_group_id = oci_core_network_security_group.sg_flb.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = var.source_ip
  stateless                 = false
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group" "sg_compute" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "sg-compute"
  defined_tags   = local.common_defined_tags
}

resource "oci_core_network_security_group_security_rule" "sg_compute_ingress_http" {
  network_security_group_id = oci_core_network_security_group.sg_compute.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = oci_core_network_security_group.sg_flb.id
  stateless                 = false
  source_type               = "NETWORK_SECURITY_GROUP"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "sg_compute_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.sg_compute.id
  protocol                  = "6"
  direction                 = "INGRESS"
  source                    = "10.0.2.0/24"
  stateless                 = false
  source_type               = "CIDR_BLOCK"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "sg_compute_egress_all" {
  network_security_group_id = oci_core_network_security_group.sg_compute.id
  protocol                  = "all"
  direction                 = "EGRESS"
  destination               = "0.0.0.0/0"
  stateless                 = false
  destination_type          = "CIDR_BLOCK"
}