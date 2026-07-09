terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = "terraform-vpn"
}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  availability_zone = coalesce(var.availability_zone, data.aws_availability_zones.available.names[0])
}

# Lightsail instance running 3x-ui, bootstrapped via the same cloud-init used for EC2.
resource "aws_lightsail_instance" "vpn" {
  name              = "vpn-server"
  availability_zone = local.availability_zone
  blueprint_id      = var.blueprint_id
  bundle_id         = var.bundle_id
  user_data         = file("${path.module}/cloud-init.yaml")

  tags = {
    Name = "vpn-server"
  }
}

# Static IP is free while attached to a running Lightsail instance.
resource "aws_lightsail_static_ip" "vpn_ip" {
  name = "vpn-static-ip"
}

resource "aws_lightsail_static_ip_attachment" "vpn_ip_attach" {
  static_ip_name = aws_lightsail_static_ip.vpn_ip.name
  instance_name  = aws_lightsail_instance.vpn.name
}

# Defining this resource replaces ALL default firewall rules, so SSH must be listed explicitly.
resource "aws_lightsail_instance_public_ports" "vpn_ports" {
  instance_name = aws_lightsail_instance.vpn.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }

  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }

  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  }

  port_info {
    protocol  = "tcp"
    from_port = var.panel_port
    to_port   = var.panel_port
  }
}
