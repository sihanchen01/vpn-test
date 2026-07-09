output "public_ip" {
  value = aws_lightsail_static_ip.vpn_ip.ip_address
}

output "panel_url" {
  value = "https://${aws_lightsail_static_ip.vpn_ip.ip_address}:${var.panel_port}"
}

output "instance_name" {
  value = aws_lightsail_instance.vpn.name
}
