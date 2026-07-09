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

# Latest Ubuntu 24.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

data "aws_iam_instance_profile" "ssm_profile" {
  name = "ec2-ssm-role"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security group
resource "aws_security_group" "vpn_sg" {
  name        = "vpn-sg"
  description = "VPN server security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 2053
    to_port     = 2053
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Elastic IP
resource "aws_eip" "vpn_eip" {
  instance = aws_instance.vpn.id
  domain   = "vpc"
}


# EC2 instance
resource "aws_instance" "vpn" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = tolist(data.aws_subnets.default.ids)[0]
  iam_instance_profile   = data.aws_iam_instance_profile.ssm_profile.name
  vpc_security_group_ids = [aws_security_group.vpn_sg.id]

  # Fix for SSM IMDSv2 optional
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }

  user_data = file("${path.module}/cloud-init.yaml")

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name = "vpn-server"
  }
}
