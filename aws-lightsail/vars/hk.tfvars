region    = "ap-east-1"
bundle_id = "micro_3_1"

allowed_ports = [
  {
    protocol   = "tcp"
    from_port  = 22
    to_port    = 22
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  },
  {
    protocol   = "tcp"
    from_port  = 443
    to_port    = 443
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  },

  {
    protocol   = "tcp"
    from_port  = 80
    to_port    = 80
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  },

  {
    protocol   = "tcp"
    from_port  = 2053
    to_port    = 2053
    cidrs      = ["0.0.0.0/0"]
    ipv6_cidrs = ["::/0"]
  }
]

