output "public_ip" {
  value = aws_eip.vpn_eip.public_ip
}

output "panel_url" {
  value = "https://${aws_eip.vpn_eip.public_ip}:${var.panel_port}"
}

output "instance_id" {
  value = aws_instance.vpn.id
}
