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
resource "oci_core_security_list" "sl" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nothing-security-list"
  defined_tags   = local.common_defined_tags
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
  security_list_ids = [oci_core_security_list.sl.id]
  # prohibit_internet_ingress と prohibit_public_ip_on_vnic は 同様の動き
  # そのため、２つのパラメータの true/false を互い違いにするとconflictでエラーとなる
  # 基本的には、値を揃えるか、どちらか一方を明記すること
  prohibit_internet_ingress  = false
  prohibit_public_ip_on_vnic = false
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
NAT Gateway
************************************************************/
resource "oci_core_nat_gateway" "ngw" {
  compartment_id = oci_identity_compartment.workload.id
  display_name   = "ngw"
  vcn_id         = oci_core_vcn.vcn.id
  block_traffic  = false
  defined_tags = local.common_defined_tags
}

/************************************************************
Route Table
************************************************************/
resource "oci_core_route_table" "rtb_flb" {
  compartment_id = oci_identity_compartment.workload.id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "rtb"
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