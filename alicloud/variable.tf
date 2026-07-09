variable "region" {
  description = "AliCloud region to deploy into"
}

variable "access_key" {
  description = "AliCloud access key ID"
  sensitive   = true
}

variable "secret_key" {
  description = "AliCloud access key secret"
  sensitive   = true
}

variable "instance_type" {
  default = "ecs.t6-c1m1.small"
}

variable "instance_password" {
  description = "Root password for the ECS instance"
  sensitive   = true
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
