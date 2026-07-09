#!/bin/bash
set -e

# Variables passed from Terraform
PANEL_PORT="${panel_port}"
PANEL_USER="${panel_username}"
PANEL_PASS="${panel_password}"

# Install acme.sh before 3x-ui so the IP cert step can find it
curl https://get.acme.sh | sh -s email=sihanchen01@gmail.com
source /root/.bashrc || true

# Force HOME to /root so acme.sh installs to /root/.acme.sh/ (cloud-init may not set it)
export HOME=/root

# Install 3X-UI non-interactively
export DEBIAN_FRONTEND=noninteractive
bash <(curl -Ls https://raw.githubusercontent.com/mhsanaei/3x-ui/master/install.sh) <<EOF
1
y
$PANEL_PORT
2

80
EOF

# Wait for x-ui to start
sleep 5
systemctl start x-ui || true
sleep 5

# Set credentials via CLI
x-ui <<EOF
6
y
$PANEL_USER
$PANEL_PASS
y
y
EOF

echo "Setup complete."
