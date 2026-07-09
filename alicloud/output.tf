output "public_ip" {
  value = alicloud_eip_address.vpn_eip.ip_address
}

output "panel_url" {
  value = "https://${alicloud_eip_address.vpn_eip.ip_address}:${var.panel_port}"
}

output "instance_id" {
  value = alicloud_instance.vpn.id
}
