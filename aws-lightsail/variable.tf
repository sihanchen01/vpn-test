variable "region" {
  description = "AWS region to deploy into"
  default     = "ap-northeast-1" # Tokyo
}

variable "availability_zone" {
  description = "Lightsail availability zone; defaults to the first available AZ in the region if unset"
  type        = string
  default     = null
}

variable "blueprint_id" {
  description = "Lightsail OS blueprint"
  default     = "ubuntu_24_04"
}

variable "bundle_id" {
  description = "Lightsail plan id. small_3_0 = 2GB RAM / ~3TB transfer (~$12/mo, recommended). micro_3_0 = 1GB / 2TB (~$5/mo)"
  default     = "small_3_0"
}

variable "panel_port" {
  default = "2053"
}
