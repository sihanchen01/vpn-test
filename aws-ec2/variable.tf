variable "region" {
  description = "AWS region to deploy into"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "panel_port" {
  default = "2053"
}

variable "panel_username" {
  default = "sihan"
}

variable "panel_password" {
  description = "3X-UI panel admin password"
  default     = "chensihan"
  sensitive   = true
}
