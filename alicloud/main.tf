terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.0"
    }
  }
}

provider "alicloud" {
  region  = var.region
  profile = "default"
}

data "alicloud_zones" "available" {
  available_resource_creation = "Instance"
  available_instance_type     = var.instance_type
}

# Latest Ubuntu 24.04 image
data "alicloud_images" "ubuntu" {
  most_recent = true
  owners      = "system"
  name_regex  = "^ubuntu_24_04.*64"
}

resource "alicloud_vpc" "vpn_vpc" {
  vpc_name   = "vpn-vpc"
  cidr_block = "10.0.0.0/16"
}

resource "alicloud_vswitch" "vpn_vsw" {
  vswitch_name = "vpn-vsw"
  cidr_block   = "10.0.1.0/24"
  vpc_id       = alicloud_vpc.vpn_vpc.id
  zone_id      = data.alicloud_zones.available.zones[0].id
}

resource "alicloud_security_group" "vpn_sg" {
  name   = "vpn-sg"
  vpc_id = alicloud_vpc.vpn_vpc.id
}

resource "alicloud_security_group_rule" "allow_443" {
  type              = "ingress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "443/443"
  security_group_id = alicloud_security_group.vpn_sg.id
}

resource "alicloud_security_group_rule" "allow_80" {
  type              = "ingress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "80/80"
  security_group_id = alicloud_security_group.vpn_sg.id
}

resource "alicloud_security_group_rule" "allow_panel" {
  type              = "ingress"
  ip_protocol       = "tcp"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "${var.panel_port}/${var.panel_port}"
  security_group_id = alicloud_security_group.vpn_sg.id
}

resource "alicloud_security_group_rule" "allow_egress" {
  type              = "egress"
  ip_protocol       = "all"
  cidr_ip           = "0.0.0.0/0"
  port_range        = "-1/-1"
  security_group_id = alicloud_security_group.vpn_sg.id
}

resource "alicloud_instance" "vpn" {
  image_id        = data.alicloud_images.ubuntu.ids[0]
  instance_type   = var.instance_type
  vswitch_id      = alicloud_vswitch.vpn_vsw.id
  security_groups = [alicloud_security_group.vpn_sg.id]
  instance_name   = "vpn-server"
  password        = var.instance_password

  system_disk_category = "cloud_essd"
  system_disk_size     = 40

  # No instance-level public IP; EIP handles outbound
  internet_max_bandwidth_out = 0

  user_data = templatefile("${path.module}/user_data.sh", {
    panel_port     = var.panel_port
    panel_username = var.panel_username
    panel_password = var.panel_password
  })

  tags = {
    Name = "vpn-server"
  }
}

resource "alicloud_eip_address" "vpn_eip" {
  address_name         = "vpn-eip"
  payment_type         = "PayAsYouGo"
  bandwidth            = "100"
  internet_charge_type = "PayByTraffic"
}

resource "alicloud_eip_association" "vpn_eip_assoc" {
  allocation_id = alicloud_eip_address.vpn_eip.id
  instance_id   = alicloud_instance.vpn.id
}
