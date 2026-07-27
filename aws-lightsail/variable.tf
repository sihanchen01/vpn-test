variable "region" {
  type        = string
  description = "AWS region to deploy into"
  default     = "ap-northeast-1" # Tokyo
}

variable "availability_zone" {
  description = "Lightsail availability zone; defaults to the first available AZ in the region if unset"
  type        = string
  default     = null
}

variable "blueprint_id" {
  type        = string
  description = "Lightsail OS blueprint"
  default     = "ubuntu_24_04"
}

variable "bundle_id" {
  type        = string
  description = "Lightsail plan id. small_3_0 = 2GB RAM / ~1TB transfer (~$12/mo, recommended). micro_3_0 = 1GB RAM / 2 vCPU / 2TB (~$7/mo)"
  default     = "micro_3_0"
}

variable "panel_port" {
  type        = string
  description = "Port for the panel"
  default     = "2053"

}

variable "allowed_ports" {
  description = "List of allowed ports. Each contains a protocol, from_port, to_port, cidrs and ipv6_cidrs"
  type = list(object({
    protocol   = string
    from_port  = number
    to_port    = number
    cidrs      = list(string)
    ipv6_cidrs = list(string)
  }))
}
